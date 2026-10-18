/* =====================================================================
   PoliMusic - assets/js/app.js
   Lógica del cliente: reproductor de audio, cola de reproducción,
   búsqueda, menú lateral, toasts y confirmaciones.
   Las pistas se leen de SongFiles/ (ruta completa en data-file) y
   cada reproducción incrementa PLAYS vía play_count.asp.
   ===================================================================== */
(function () {
    "use strict";

    var audio = document.getElementById("pmAudio");
    var btnToggle = document.getElementById("pmToggle");
    var btnPrev = document.getElementById("pmPrev");
    var btnNext = document.getElementById("pmNext");
    var seek = document.getElementById("pmSeek");
    var volume = document.getElementById("pmVolume");
    var curLabel = document.getElementById("pmCurrent");
    var durLabel = document.getElementById("pmDuration");
    var titleLabel = document.getElementById("pmTitle");
    var artistLabel = document.getElementById("pmArtist");
    var coverBox = document.getElementById("pmCover");

    var ICON_PLAY = '<svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M7 4.5v15l13-7.5z"/></svg>';
    var ICON_PAUSE = '<svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><rect x="6" y="4.5" width="4" height="15" rx="1"/><rect x="14" y="4.5" width="4" height="15" rx="1"/></svg>';
    var ICON_MUSIC = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg>';

    // Cola: se construye a partir de las filas de la tabla con data-file
    var queue = [];
    var current = -1;
    var seeking = false;

    function collectQueue() {
        queue = [];
        var rows = document.querySelectorAll("tr[data-file]");
        for (var i = 0; i < rows.length; i++) {
            queue.push({
                el: rows[i],
                id: rows[i].getAttribute("data-id") || "",
                file: rows[i].getAttribute("data-file"),
                title: rows[i].getAttribute("data-title") || "Sin título",
                artist: rows[i].getAttribute("data-artist") || "Artista desconocido"
            });
        }
    }

    function fmt(sec) {
        if (!isFinite(sec) || sec < 0) sec = 0;
        var m = Math.floor(sec / 60);
        var s = Math.floor(sec % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    function markPlayingRow() {
        var rows = document.querySelectorAll("tr[data-file]");
        for (var i = 0; i < rows.length; i++) rows[i].classList.remove("is-playing");
        if (current >= 0 && queue[current] && queue[current].el) {
            queue[current].el.classList.add("is-playing");
        }
    }

    // Incrementa el contador de reproducciones (PLAZS -> PLAYS) en el servidor
    function registerPlay(songId) {
        if (!songId) return;
        try {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "play_count.asp", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.send("id=" + encodeURIComponent(songId));
        } catch (e) { /* silencioso: el contador es informativo */ }
    }

    function loadTrack(index, autoplay) {
        if (index < 0 || index >= queue.length) return;
        current = index;
        var track = queue[index];

        audio.src = encodeURI(track.file);
        audio.load();

        titleLabel.textContent = track.title;
        artistLabel.textContent = track.artist;
        coverBox.innerHTML = ICON_MUSIC;
        curLabel.textContent = "0:00";
        durLabel.textContent = "0:00";
        seek.value = 0;
        markPlayingRow();
        registerPlay(track.id);

        if (autoplay) {
            var p = audio.play();
            if (p && typeof p.catch === "function") {
                p["catch"](function () {
                    toast("No se pudo reproducir \"" + track.title + "\". Verifica que el archivo exista en SongFiles/.", "error");
                });
            }
        }
    }

    function togglePlay() {
        if (current < 0) {
            if (queue.length > 0) loadTrack(0, true);
            else toast("No hay canciones disponibles para reproducir.", "error");
            return;
        }
        if (audio.paused) {
            var p = audio.play();
            if (p && typeof p.catch === "function") {
                p["catch"](function () { toast("No se pudo reproducir el archivo. Revisa la carpeta SongFiles/.", "error"); });
            }
        } else {
            audio.pause();
        }
    }

    function next() {
        if (queue.length === 0) return;
        loadTrack((current + 1) % queue.length, true);
    }

    function prev() {
        if (queue.length === 0) return;
        loadTrack((current - 1 + queue.length) % queue.length, true);
    }

    if (audio && btnToggle) {
        collectQueue();

        btnToggle.addEventListener("click", togglePlay);
        btnNext.addEventListener("click", next);
        btnPrev.addEventListener("click", prev);

        audio.addEventListener("play", function () { btnToggle.innerHTML = ICON_PAUSE; btnToggle.setAttribute("aria-label", "Pausar"); });
        audio.addEventListener("pause", function () { btnToggle.innerHTML = ICON_PLAY; btnToggle.setAttribute("aria-label", "Reproducir"); });

        audio.addEventListener("timeupdate", function () {
            if (!seeking && isFinite(audio.duration)) {
                seek.value = audio.currentTime;
                seek.max = audio.duration;
                curLabel.textContent = fmt(audio.currentTime);
            }
        });

        audio.addEventListener("loadedmetadata", function () {
            if (isFinite(audio.duration)) {
                seek.max = audio.duration;
                durLabel.textContent = fmt(audio.duration);
            }
        });

        audio.addEventListener("ended", next);

        audio.addEventListener("error", function () {
            if (audio.getAttribute("src")) {
                toast("No se pudo cargar el audio. Verifica que el archivo .mp3 exista en SongFiles/.", "error");
            }
        });

        seek.addEventListener("input", function () { seeking = true; curLabel.textContent = fmt(parseFloat(seek.value)); });
        seek.addEventListener("change", function () {
            if (isFinite(audio.duration)) audio.currentTime = parseFloat(seek.value);
            seeking = false;
        });

        var savedVol = null;
        try { savedVol = window.localStorage.getItem("pm-volume"); } catch (e) { /* modo privado */ }
        audio.volume = savedVol !== null ? parseFloat(savedVol) : 0.8;
        volume.value = audio.volume;
        volume.addEventListener("input", function () {
            audio.volume = parseFloat(volume.value);
            try { window.localStorage.setItem("pm-volume", volume.value); } catch (e) { /* modo privado */ }
        });

        // Clic en el botón de reproducción de una fila de la tabla
        document.addEventListener("click", function (ev) {
            var btn = ev.target.closest ? ev.target.closest(".row-play") : null;
            if (!btn) return;
            var row = btn.closest("tr[data-file]");
            if (!row) return;
            var rows = Array.prototype.slice.call(document.querySelectorAll("tr[data-file]"));
            var idx = rows.indexOf(row);
            if (idx === current && !audio.paused) {
                audio.pause();
            } else {
                loadTrack(idx, true);
            }
        });

        // Botón "Reproducir todo"
        var playAll = document.getElementById("playAllBtn");
        if (playAll) {
            playAll.addEventListener("click", function () {
                if (queue.length > 0) loadTrack(0, true);
                else toast("No hay canciones en la lista.", "error");
            });
        }

        // Botón flotante en tarjetas (listas/álbumes): abre el detalle
        document.addEventListener("click", function (ev) {
            var fab = ev.target.closest ? ev.target.closest(".play-fab") : null;
            if (!fab) return;
            var card = fab.closest(".playlist-card");
            var href = card ? card.getAttribute("data-href") : null;
            if (href) window.location.href = href;
        });
    }

    // Búsqueda / filtro de la tabla de canciones
    var searchInput = document.getElementById("songSearch");
    if (searchInput) {
        searchInput.addEventListener("input", function () {
            var q = searchInput.value.trim().toLowerCase();
            var rows = document.querySelectorAll("tr[data-file]");
            var visible = 0;
            rows.forEach(function (row) {
                var hay = (row.textContent || "").toLowerCase();
                var show = q === "" || hay.indexOf(q) !== -1;
                row.style.display = show ? "" : "none";
                if (show) visible++;
            });
            var counter = document.getElementById("songCount");
            if (counter) counter.textContent = visible + (visible === 1 ? " canción" : " canciones");
        });
    }

    // Menú lateral (responsive)
    var sidebar = document.getElementById("sidebar");
    var menuToggle = document.getElementById("menuToggle");
    var sidebarClose = document.getElementById("sidebarClose");
    var backdrop = document.getElementById("sidebarBackdrop");

    function closeSidebar() { if (sidebar) sidebar.classList.remove("open"); }
    if (menuToggle) menuToggle.addEventListener("click", function () { sidebar.classList.toggle("open"); });
    if (sidebarClose) sidebarClose.addEventListener("click", closeSidebar);
    if (backdrop) backdrop.addEventListener("click", closeSidebar);

    // Cerrar mensajes flash
    document.querySelectorAll(".flash-close").forEach(function (btn) {
        btn.addEventListener("click", function () {
            var flash = btn.closest(".flash");
            if (flash) flash.style.display = "none";
        });
    });

    // Confirmación de eliminación
    document.querySelectorAll("form[data-confirm]").forEach(function (form) {
        form.addEventListener("submit", function (ev) {
            if (!window.confirm(form.getAttribute("data-confirm"))) {
                ev.preventDefault();
            }
        });
    });

    // Toasts
    window.toast = function (message, kind) {
        var wrap = document.getElementById("toastWrap");
        if (!wrap) return;
        var t = document.createElement("div");
        t.className = "toast" + (kind === "error" ? " error" : "");
        t.textContent = message;
        wrap.appendChild(t);
        setTimeout(function () {
            t.classList.add("hide");
            setTimeout(function () { if (t.parentNode) t.parentNode.removeChild(t); }, 350);
        }, 3800);
    };
})();
