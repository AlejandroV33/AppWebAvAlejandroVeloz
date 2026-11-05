<%@ Page Title="Canciones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.Song" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    /* ---------------------------------------------------------------
       Design tokens — MetaMusic style reference (DESIGN.md)
       --------------------------------------------------------------- */
    :root {
        --color-brand-blue: #0066cc;
        --color-deep-indigo: #0e2575;
        --color-midnight-card: #213680;
        --color-charcoal-ink: #101820;
        --color-paper-cream: #f4f1ea;
        --color-white: #ffffff;
        --color-lavender-mist: #e6e0f8;
        --color-ice-blue: #e9f4ff;
        --color-peach-blush: #f7e1d5;
        --color-ash-border: #d6d6d6;
        --font-maison-neue: 'Maison Neue', Inter, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        --shadow-subtle: 0px 4px 0px 0px #000000;
        --page-max-width: 1280px;
        --radius-cards: 24px;
        --radius-inputs: 8px;
        --radius-buttons: 9999px;
    }

    /* Neutraliza el esqueleto Bootstrap del Site.Master solo en esta pagina */
    body { background: var(--color-paper-cream) !important; color: var(--color-charcoal-ink); font-family: var(--font-maison-neue); overflow-x: hidden; }
    .container.body-content { max-width: var(--page-max-width) !important; padding: 0 24px !important; margin: 0 auto !important; }
    .body-content > hr, .body-content > footer { display: none !important; }
    .navbar.navbar-dark.bg-dark { background: var(--color-white) !important; height: 64px; padding: 0 24px; border-bottom: 1px solid var(--color-ash-border); }
    .navbar .navbar-brand { color: var(--color-brand-blue) !important; font-weight: 600; font-size: 19px; letter-spacing: -0.01em; }
    .navbar .nav-link { color: var(--color-charcoal-ink) !important; font-size: 16px; font-weight: 500; }
    .navbar .nav-link:hover, .navbar .nav-link:focus { color: var(--color-brand-blue) !important; }
    .navbar-nav .nav-item:last-child .nav-link { border: 1px solid #000000; border-radius: var(--radius-buttons); padding: 8px 20px; box-shadow: var(--shadow-subtle); background: var(--color-white); }
    .pm-app input, .pm-player input { max-width: none !important; }
    [hidden] { display: none !important; }

    .pm-app { max-width: var(--page-max-width); margin: 0 auto; padding-bottom: 150px; }
    .pm-eyebrow { color: var(--color-brand-blue); font-size: 16px; font-weight: 500; margin: 0 0 16px; }
    .pm-eyebrow--light { color: #8fb4ff; }

    /* Notification banner */
    .pm-banner { display: flex; align-items: center; gap: 12px; background: var(--color-lavender-mist); border-radius: var(--radius-inputs); padding: 8px 16px; margin-top: 24px; font-size: 13px; line-height: 1.4; }
    .pm-banner__dot { width: 8px; height: 8px; border-radius: 50%; background: var(--color-brand-blue); flex: none; }
    .pm-banner__close { margin-left: auto; border: 0; background: transparent; font-size: 20px; line-height: 1; cursor: pointer; color: var(--color-charcoal-ink); }

    /* Hero */
    .pm-hero { display: grid; grid-template-columns: minmax(0, 1fr) 240px; gap: 40px; align-items: center; padding: 64px 0 80px; }
    .pm-hero__title { font-size: clamp(44px, 6vw, 80px); line-height: 1.05; letter-spacing: -0.02em; font-weight: 600; margin: 0 0 24px; }
    .pm-hero__name { display: block; color: var(--color-brand-blue); }
    .pm-hero__sub { font-size: 19px; line-height: 1.4; max-width: 560px; margin: 0 0 32px; }
    .pm-hero__actions { display: flex; align-items: center; gap: 32px; flex-wrap: wrap; }
    .pm-btn { font-family: inherit; font-size: 16px; font-weight: 500; border: 0; border-radius: var(--radius-buttons); padding: 16px 24px; cursor: pointer; display: inline-flex; align-items: center; gap: 10px; box-shadow: var(--shadow-subtle); transition: transform .15s ease, box-shadow .15s ease; }
    .pm-btn--primary { background: var(--color-brand-blue); color: var(--color-white); }
    .pm-btn:active { transform: translateY(2px); box-shadow: 0 2px 0 0 #000000; }
    .pm-btn svg { width: 18px; height: 18px; }
    .pm-link { color: var(--color-brand-blue); font-weight: 500; text-decoration: none; border-bottom: 2px solid currentColor; padding-bottom: 2px; font-size: 16px; }
    .pm-hero__art { display: flex; justify-content: center; }
    .pm-illustration { width: 200px; height: 200px; border-radius: 50%; background: var(--color-peach-blush); display: grid; place-items: center; color: var(--color-brand-blue); }
    .pm-illustration svg { width: 96px; height: 96px; }

    /* Cards */
    .pm-grid { display: grid; grid-template-columns: 320px minmax(0, 1fr); gap: 24px; align-items: start; }
    .pm-card { background: var(--color-white); border-radius: var(--radius-cards); padding: 40px; }
    .pm-card__title { font-size: 32px; line-height: 1.2; letter-spacing: -0.01em; font-weight: 600; margin: 0 0 24px; }
    .pm-card + .pm-card { margin-top: 24px; }
    .pm-user { display: flex; align-items: center; gap: 16px; }
    .pm-user__avatar { width: 56px; height: 56px; border-radius: 50%; overflow: hidden; background: var(--color-peach-blush); flex: none; display: grid; place-items: center; font-weight: 600; color: var(--color-brand-blue); }
    .pm-user__avatar img { width: 100%; height: 100%; object-fit: cover; }
    .pm-user__names { display: flex; flex-direction: column; min-width: 0; }
    .pm-user__names strong { font-size: 19px; font-weight: 500; word-break: break-all; }
    .pm-user__names small { font-size: 14px; color: #5b6270; }
    .pm-user__meta { margin: 32px 0 0; padding: 24px 0 0; border-top: 1px solid var(--color-ash-border); font-size: 14px; }
    .pm-user__meta dt { color: #5b6270; margin-top: 12px; }
    .pm-user__meta dd { margin: 2px 0 0; font-weight: 500; word-break: break-all; }
    .pm-chips { display: flex; flex-wrap: wrap; gap: 8px; }
    .pm-chip { font-family: inherit; font-size: 14px; padding: 10px 18px; border-radius: var(--radius-buttons); border: 1px solid var(--color-ash-border); background: var(--color-white); color: var(--color-charcoal-ink); cursor: pointer; }
    .pm-chip.is-active { background: var(--color-ice-blue); border-color: var(--color-brand-blue); color: var(--color-brand-blue); font-weight: 500; }
    .pm-rail__list { list-style: none; padding: 0; margin: 32px 0 0; }
    .pm-rail__list li { display: flex; align-items: center; gap: 12px; padding: 14px 0; border-bottom: 1px solid var(--color-ash-border); font-size: 14px; }
    .pm-rail__list li span:last-child { margin-left: auto; color: #5b6270; }

    /* Library */
    .pm-library__head { display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; }
    .pm-count { background: var(--color-ice-blue); color: var(--color-brand-blue); border-radius: var(--radius-buttons); padding: 8px 16px; font-size: 14px; font-weight: 500; white-space: nowrap; }
    .pm-search { display: flex; align-items: center; gap: 12px; background: var(--color-white); border: 1px solid var(--color-lavender-mist); border-radius: var(--radius-inputs); padding: 12px 16px; margin: 24px 0 32px; }
    .pm-search:focus-within { border-color: var(--color-brand-blue); }
    .pm-search svg { width: 20px; height: 20px; color: var(--color-brand-blue); flex: none; }
    .pm-search__input { border: 0; outline: 0; flex: 1; min-width: 0; font: inherit; font-size: 16px; background: transparent; color: var(--color-charcoal-ink); }
    .pm-list__head, .pm-row { display: grid; grid-template-columns: 36px 48px minmax(0, 1fr) 150px 90px 40px; gap: 16px; align-items: center; }
    .pm-list__head { font-size: 12px; letter-spacing: .08em; text-transform: uppercase; color: #5b6270; padding: 0 12px 12px; border-bottom: 1px solid var(--color-ash-border); }
    .pm-list { margin-top: 8px; }
    .pm-row { padding: 12px; border-radius: 16px; cursor: pointer; transition: background .15s ease; outline: 0; }
    .pm-row:hover, .pm-row:focus-visible { background: var(--color-ice-blue); }
    .pm-row.is-active { background: var(--color-ice-blue); box-shadow: inset 3px 0 0 var(--color-brand-blue); }
    .pm-row__index { font-size: 14px; color: #5b6270; font-variant-numeric: tabular-nums; }
    .pm-row__cover, .pm-player__cover { display: grid; place-items: center; color: var(--color-brand-blue); background: var(--color-peach-blush); }
    .pm-row__cover { width: 48px; height: 48px; border-radius: 16px; }
    .pm-cover--1 { background: var(--color-peach-blush); }
    .pm-cover--2 { background: var(--color-ice-blue); }
    .pm-cover--3 { background: var(--color-lavender-mist); }
    .pm-row__cover svg, .pm-player__cover svg { width: 24px; height: 24px; }
    .pm-row__info { min-width: 0; display: flex; flex-direction: column; gap: 2px; }
    .pm-row__title { font-weight: 500; font-size: 16px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .pm-row__artist { font-size: 14px; color: #5b6270; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .pm-row__album { font-size: 14px; color: #5b6270; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .pm-row__plays { font-size: 14px; font-variant-numeric: tabular-nums; color: #5b6270; display: flex; align-items: center; gap: 6px; }
    .pm-row__plays svg { width: 14px; height: 14px; }
    .pm-row__play { width: 40px; height: 40px; border-radius: 50%; background: #000000; color: var(--color-white); display: grid; place-items: center; }
    .pm-row__play svg { width: 16px; height: 16px; }
    .pm-row.is-active .pm-row__play { background: var(--color-brand-blue); }
    .pm-row__badge { font-size: 11px; background: var(--color-lavender-mist); border-radius: var(--radius-buttons); padding: 2px 8px; margin-left: 8px; white-space: nowrap; }
    .pm-empty { padding: 48px 12px; font-size: 16px; color: #5b6270; }
    .pm-alert { background: var(--color-lavender-mist); border-radius: var(--radius-inputs); padding: 16px; font-size: 14px; margin-top: 16px; }

    /* Deep indigo feature band */
    .pm-features { background: var(--color-deep-indigo); color: var(--color-white); width: 100vw; margin-left: calc(50% - 50vw); margin-top: 80px; padding: 80px 24px; }
    .pm-features__inner { max-width: var(--page-max-width); margin: 0 auto; }
    .pm-features__title { font-size: 56px; line-height: 1.05; letter-spacing: -0.02em; font-weight: 600; margin: 0 0 40px; max-width: 900px; }
    .pm-feature-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 24px; }
    .pm-feature { background: var(--color-midnight-card); border-radius: var(--radius-cards); padding: 40px; }
    .pm-feature__num { width: 32px; height: 32px; border-radius: 50%; background: var(--color-brand-blue); display: grid; place-items: center; font-size: 14px; font-weight: 500; margin-bottom: 24px; }
    .pm-feature__value { font-size: 40px; line-height: 1.1; letter-spacing: -0.02em; font-weight: 600; margin: 0; }
    .pm-feature h3 { font-size: 22px; font-weight: 500; margin: 8px 0 8px; }
    .pm-feature p:last-child { font-size: 16px; line-height: 1.4; margin: 0; color: #d7e1ff; }
    .pm-features__link { display: inline-block; color: #8fb4ff; font-size: 16px; font-weight: 500; margin-top: 32px; text-decoration: none; border-bottom: 2px solid currentColor; padding-bottom: 2px; }
    .pm-footer { display: flex; justify-content: space-between; gap: 16px; flex-wrap: wrap; padding: 40px 0 0; margin-top: 40px; border-top: 1px solid var(--color-ash-border); font-size: 12px; color: #5b6270; }

    /* Sticky player */
    .pm-player { position: fixed; left: 0; right: 0; bottom: 0; z-index: 50; background: var(--color-white); border-top: 1px solid var(--color-ash-border); display: grid; grid-template-columns: minmax(180px, 1fr) minmax(300px, 2fr) minmax(180px, 1fr); gap: 24px; align-items: center; padding: 14px 32px; }
    .pm-player__track { display: flex; align-items: center; gap: 14px; min-width: 0; }
    .pm-player__cover { width: 52px; height: 52px; border-radius: 16px; flex: none; }
    .pm-player__meta { min-width: 0; }
    .pm-player__meta strong { display: block; font-size: 15px; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .pm-player__meta small { display: block; font-size: 13px; color: #5b6270; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .pm-player__center { display: flex; flex-direction: column; align-items: center; gap: 8px; min-width: 0; }
    .pm-controls { display: flex; align-items: center; gap: 16px; }
    .pm-ctrl { border: 0; background: transparent; color: var(--color-charcoal-ink); cursor: pointer; width: 32px; height: 32px; display: grid; place-items: center; padding: 0; }
    .pm-ctrl svg { width: 20px; height: 20px; }
    .pm-ctrl.is-active { color: var(--color-brand-blue); }
    .pm-ctrl--main { width: 44px; height: 44px; border-radius: 50%; background: #000000; color: var(--color-white); box-shadow: var(--shadow-subtle); }
    .pm-ctrl--main .pm-icon--pause { display: none; }
    .pm-ctrl--main.is-playing .pm-icon--play { display: none; }
    .pm-ctrl--main.is-playing .pm-icon--pause { display: block; }
    .pm-seekline { display: flex; align-items: center; gap: 12px; width: 100%; max-width: 560px; }
    .pm-time { font-size: 12px; color: #5b6270; font-variant-numeric: tabular-nums; min-width: 38px; }
    .pm-seek, .pm-volume { -webkit-appearance: none; appearance: none; height: 6px; border-radius: var(--radius-buttons); outline: 0; cursor: pointer; }
    .pm-seek { flex: 1; min-width: 0; background: linear-gradient(to right, var(--color-brand-blue) var(--pct, 0%), var(--color-ash-border) var(--pct, 0%)); }
    .pm-volume { width: 90px; background: linear-gradient(to right, var(--color-brand-blue) var(--vpct, 80%), var(--color-ash-border) var(--vpct, 80%)); }
    .pm-seek::-webkit-slider-thumb, .pm-volume::-webkit-slider-thumb { -webkit-appearance: none; width: 14px; height: 14px; border-radius: 50%; background: var(--color-brand-blue); border: 2px solid var(--color-white); box-shadow: 0 0 0 1px var(--color-brand-blue); }
    .pm-seek::-moz-range-thumb, .pm-volume::-moz-range-thumb { width: 12px; height: 12px; border-radius: 50%; background: var(--color-brand-blue); border: 2px solid var(--color-white); }
    .pm-player__right { display: flex; align-items: center; justify-content: flex-end; gap: 12px; }
    .pm-session { font-size: 12px; color: #5b6270; white-space: nowrap; }
    .pm-lang { display: flex; align-items: center; gap: 6px; font-size: 14px; }
    .pm-lang svg { width: 18px; height: 18px; }
    #upPlays { display: flex; align-items: center; }
    .pm-toast { position: fixed; left: 50%; bottom: 120px; transform: translate(-50%, 12px); background: var(--color-charcoal-ink); color: var(--color-white); padding: 14px 22px; border-radius: var(--radius-buttons); font-size: 14px; opacity: 0; pointer-events: none; transition: all .2s ease; z-index: 60; max-width: 90vw; text-align: center; }
    .pm-toast.is-visible { opacity: 1; transform: translate(-50%, 0); }

    @media (max-width: 1100px) {
        .pm-grid { grid-template-columns: 1fr; }
        .pm-hero { grid-template-columns: minmax(0, 1fr) 160px; }
        .pm-illustration { width: 150px; height: 150px; }
        .pm-illustration svg { width: 72px; height: 72px; }
        .pm-feature-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .pm-player { grid-template-columns: minmax(160px, 1fr) minmax(300px, 2fr); }
        .pm-player__right { display: none; }
    }
    @media (max-width: 760px) {
        .container.body-content { padding: 0 16px !important; }
        .pm-hero { grid-template-columns: 1fr; padding: 40px 0 48px; }
        .pm-hero__art { display: none; }
        .pm-card { padding: 24px; }
        .pm-card__title { font-size: 26px; }
        .pm-list__head, .pm-row { grid-template-columns: 24px 44px minmax(0, 1fr) 40px; gap: 12px; }
        .pm-list__head span:nth-child(4), .pm-list__head span:nth-child(5), .pm-row__album, .pm-row__plays { display: none; }
        .pm-features__title { font-size: 40px; }
        .pm-features { padding: 56px 16px; margin-top: 56px; }
        .pm-feature-grid { grid-template-columns: 1fr; }
        .pm-feature { padding: 24px; }
        .pm-player { grid-template-columns: 1fr auto; padding: 10px 16px; }
        .pm-seekline { display: none; }
        .pm-ctrl--main { box-shadow: none; }
    }
</style>

<div class="pm-app">

    <!-- Notification banner -->
    <div class="pm-banner" id="pmBanner">
        <span class="pm-banner__dot"></span>
        <span>Tu biblioteca está sincronizada con tu cuenta de <strong>PoliMusic</strong>. Disfruta la sesión.</span>
        <button type="button" class="pm-banner__close" id="pmBannerClose" aria-label="Cerrar aviso">&times;</button>
    </div>

    <!-- Hero -->
    <header class="pm-hero">
        <div class="pm-hero__copy">
            <p class="pm-eyebrow">Descubre PoliMusic</p>
            <h1 class="pm-hero__title">Bienvenido <span class="pm-hero__name"><asp:Literal ID="litWelcome" runat="server" Mode="PassThrough" /></span></h1>
            <p class="pm-hero__sub">Tu música, sin interrupciones. Explora la biblioteca, crea tu cola de reproducción y dale play.</p>
            <div class="pm-hero__actions">
                <button type="button" class="pm-btn pm-btn--primary" id="pmPlayAll">
                    <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5l11 7-11 7z" fill="currentColor" /></svg>
                    Reproducir todo
                </button>
                <a class="pm-link" href="#pmLibrary">Explorar biblioteca &rarr;</a>
            </div>
        </div>
        <div class="pm-hero__art" aria-hidden="true">
            <span class="pm-illustration">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 18V5l10-2v13" />
                    <circle cx="6" cy="18" r="3" />
                    <circle cx="16" cy="16" r="3" />
                </svg>
            </span>
        </div>
    </header>

    <!-- Biblioteca -->
    <section class="pm-grid" id="pmLibrary">
        <aside class="pm-rail">
            <div class="pm-card">
                <p class="pm-eyebrow">Tu cuenta</p>
                <h2 class="pm-card__title">Tu perfil</h2>
                <asp:Literal ID="litUserCard" runat="server" Mode="PassThrough" />
            </div>
            <div class="pm-card">
                <p class="pm-eyebrow">Tu biblioteca</p>
                <h2 class="pm-card__title">Explora por</h2>
                <div class="pm-chips" id="pmChips">
                    <button type="button" class="pm-chip is-active" data-sort="all">Todas</button>
                    <button type="button" class="pm-chip" data-sort="top">Más escuchadas</button>
                    <button type="button" class="pm-chip" data-sort="az">A &ndash; Z</button>
                </div>
                <ul class="pm-rail__list">
                    <li><span>Canciones</span><span id="pmRailSongs">&mdash;</span></li>
                    <li><span>Artistas</span><span id="pmRailArtists">&mdash;</span></li>
                    <li><span>Álbumes</span><span id="pmRailAlbums">&mdash;</span></li>
                </ul>
            </div>
        </aside>

        <div class="pm-main">
            <div class="pm-card">
                <div class="pm-library__head">
                    <div>
                        <p class="pm-eyebrow">Biblioteca musical</p>
                        <h2 class="pm-card__title">Canciones para ti</h2>
                    </div>
                    <span class="pm-count" id="pmCount">0 pistas</span>
                </div>

                <div class="pm-search">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true">
                        <circle cx="11" cy="11" r="7" /><path d="M20 20l-4-4" />
                    </svg>
                    <input type="search" id="pmSearch" class="pm-search__input" placeholder="Busca canciones, artistas o álbumes" aria-label="Buscar en la biblioteca" autocomplete="off" />
                </div>

                <div class="pm-list__head" aria-hidden="true">
                    <span>#</span><span></span><span>Título</span><span>Álbum</span><span>Plays</span><span></span>
                </div>
                <div class="pm-list" id="pmList">
                    <asp:Literal ID="litSongRows" runat="server" Mode="PassThrough" />
                </div>
                <div class="pm-empty" id="pmEmpty" hidden>No encontramos canciones con ese criterio. Prueba con otro término.</div>
                <asp:Literal ID="litMessage" runat="server" Mode="PassThrough" />
            </div>
        </div>
    </section>

    <!-- Banda Deep Indigo -->
    <section class="pm-features">
        <div class="pm-features__inner">
            <p class="pm-eyebrow pm-eyebrow--light">PoliMusic en números</p>
            <h2 class="pm-features__title">Todo tu sonido, en un solo lugar.</h2>
            <div class="pm-feature-grid">
                <article class="pm-feature">
                    <span class="pm-feature__num">1</span>
                    <p class="pm-feature__value"><asp:Literal ID="litTotalSongs" runat="server" /></p>
                    <h3>Canciones</h3>
                    <p>Pistas disponibles en tu biblioteca.</p>
                </article>
                <article class="pm-feature">
                    <span class="pm-feature__num">2</span>
                    <p class="pm-feature__value"><asp:Literal ID="litTotalPlays" runat="server" /></p>
                    <h3>Reproducciones</h3>
                    <p>Escuchas acumuladas por la comunidad.</p>
                </article>
                <article class="pm-feature">
                    <span class="pm-feature__num">3</span>
                    <p class="pm-feature__value"><asp:Literal ID="litTotalArtists" runat="server" /></p>
                    <h3>Artistas</h3>
                    <p>Intérpretes vinculados a tus pistas.</p>
                </article>
                <article class="pm-feature">
                    <span class="pm-feature__num">4</span>
                    <p class="pm-feature__value"><asp:Literal ID="litTotalAlbums" runat="server" /></p>
                    <h3>Álbumes</h3>
                    <p>Colecciones que agrupan la música.</p>
                </article>
            </div>
            <a class="pm-features__link" href="#pmLibrary">Volver a la biblioteca &rarr;</a>
        </div>
    </section>

    <footer class="pm-footer">
        <span>PoliMusic &middot; Tu música, tu espacio.</span>
        <span>Diseño editorial · Streaming de audio HTML5</span>
    </footer>
</div>

<!-- Reproductor fijo -->
<div class="pm-player" id="pmPlayer">
    <div class="pm-player__track">
        <span class="pm-player__cover pm-cover--1" id="pmNowCover" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l10-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="16" cy="16" r="3" /></svg>
        </span>
        <span class="pm-player__meta">
            <strong id="pmNowTitle">Selecciona una canción</strong>
            <small id="pmNowArtist">Tu cola está lista</small>
        </span>
    </div>

    <div class="pm-player__center">
        <div class="pm-controls">
            <button type="button" class="pm-ctrl" id="pmShuffle" aria-label="Aleatorio" title="Aleatorio">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h4c5 0 5 12 10 12h4" /><path d="M17 3l4 3-4 3" /><path d="M3 18h4c2 0 3-2 4-4" /><path d="M14 9c1-2 2-3 4-3h3" /><path d="M17 21l4-3-4-3" /></svg>
            </button>
            <button type="button" class="pm-ctrl" id="pmPrev" aria-label="Anterior" title="Anterior">
                <svg viewBox="0 0 24 24" fill="currentColor"><path d="M6 5h2v14H6zM19 5v14l-11-7z" /></svg>
            </button>
            <button type="button" class="pm-ctrl pm-ctrl--main" id="pmToggle" aria-label="Reproducir" title="Reproducir / Pausar">
                <svg class="pm-icon pm-icon--play" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5l11 7-11 7z" /></svg>
                <svg class="pm-icon pm-icon--pause" viewBox="0 0 24 24" fill="currentColor"><path d="M7 5h3v14H7zM14 5h3v14h-3z" /></svg>
            </button>
            <button type="button" class="pm-ctrl" id="pmNext" aria-label="Siguiente" title="Siguiente">
                <svg viewBox="0 0 24 24" fill="currentColor"><path d="M16 5h2v14h-2zM5 5v14l11-7z" /></svg>
            </button>
            <button type="button" class="pm-ctrl" id="pmRepeat" aria-label="Repetir" title="Repetir">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 2l4 4-4 4" /><path d="M3 11V9a3 3 0 013-3h15" /><path d="M7 22l-4-4 4-4" /><path d="M21 13v2a3 3 0 01-3 3H3" /></svg>
            </button>
        </div>
        <div class="pm-seekline">
            <span class="pm-time" id="pmTimeNow">0:00</span>
            <input type="range" class="pm-seek" id="pmSeek" min="0" max="100" step="0.1" value="0" aria-label="Progreso de la canción" />
            <span class="pm-time" id="pmTimeTotal">0:00</span>
        </div>
    </div>

    <div class="pm-player__right">
        <button type="button" class="pm-ctrl" id="pmMute" aria-label="Silenciar" title="Silenciar">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 9v6h4l5 4V5L8 9H4z" /><path d="M17 8a5 5 0 010 8" /></svg>
        </button>
        <input type="range" class="pm-volume" id="pmVolume" min="0" max="1" step="0.01" value="0.8" aria-label="Volumen" />
        <asp:UpdatePanel ID="upPlays" runat="server" UpdateMode="Conditional" ClientIDMode="Static">
            <ContentTemplate>
                <span class="pm-session"><asp:Literal ID="litSessionPlays" runat="server" Mode="PassThrough" /></span>
                <asp:HiddenField ID="hdnPlaySongId" runat="server" ClientIDMode="Static" Value="0" />
                <asp:Button ID="btnRegisterPlay" runat="server" ClientIDMode="Static" OnClick="btnRegisterPlay_Click" Text="" UseSubmitBehavior="false" style="display:none" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <span class="pm-lang" title="Idioma">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><circle cx="12" cy="12" r="9" /><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18" /></svg>
            ES
        </span>
    </div>
</div>

<audio id="pmAudio" preload="none"></audio>
<div class="pm-toast" id="pmToast" role="status" aria-live="polite"></div>

<script>
(function () {
    'use strict';

    function byId(id) { return document.getElementById(id); }

    var audio = byId('pmAudio');
    var list = byId('pmList');
    var rows = Array.prototype.slice.call(list.querySelectorAll('.pm-row'));
    var search = byId('pmSearch');
    var empty = byId('pmEmpty');
    var count = byId('pmCount');
    var toast = byId('pmToast');
    var seek = byId('pmSeek');
    var volume = byId('pmVolume');
    var toggle = byId('pmToggle');
    var nowTitle = byId('pmNowTitle');
    var nowArtist = byId('pmNowArtist');
    var nowCover = byId('pmNowCover');
    var timeNow = byId('pmTimeNow');
    var timeTotal = byId('pmTimeTotal');

    var current = -1;
    var shuffleOn = false;
    var repeatOn = false;
    var toastTimer = null;

    function showToast(message) {
        if (!toast) { return; }
        toast.textContent = message;
        toast.className = 'pm-toast is-visible';
        if (toastTimer) { window.clearTimeout(toastTimer); }
        toastTimer = window.setTimeout(function () {
            toast.className = 'pm-toast';
        }, 3600);
    }

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0) { return '0:00'; }
        var total = Math.floor(seconds);
        var mins = Math.floor(total / 60);
        var secs = total % 60;
        return mins + ':' + (secs < 10 ? '0' : '') + secs;
    }

    function setPlayButton(playing) {
        if (!toggle) { return; }
        toggle.className = playing ? 'pm-ctrl pm-ctrl--main is-playing' : 'pm-ctrl pm-ctrl--main';
        toggle.setAttribute('aria-label', playing ? 'Pausar' : 'Reproducir');
    }

    function markActive() {
        for (var i = 0; i < rows.length; i++) {
            if (i === current) { rows[i].className = rows[i].className.replace(/\s*is-active\b/, '') + ' is-active'; }
            else { rows[i].className = rows[i].className.replace(/\s*is-active\b/, ''); }
        }
    }

    function updateNow(row) {
        nowTitle.textContent = row.getAttribute('data-title');
        nowArtist.textContent = row.getAttribute('data-artist');
        nowCover.className = 'pm-player__cover pm-cover--' + (row.getAttribute('data-tone') || '1');
        var icon = nowCover.querySelector('svg');
        if (icon) { nowCover.appendChild(icon); }
    }

    /* Registra la reproducción en la BD mediante un postback asíncrono
       (UpdatePanel): el elemento de audio queda fuera del panel y no se reinicia. */
    function registerPlay(row) {
        var hidden = byId('hdnPlaySongId');
        var button = byId('btnRegisterPlay');
        if (hidden && button) {
            hidden.value = row.getAttribute('data-id');
            button.click();
        }
        var plays = row.querySelector('.js-plays');
        if (plays) {
            var value = parseInt(plays.textContent, 10);
            if (!isNaN(value)) {
                plays.textContent = value + 1;
                row.setAttribute('data-plays', value + 1);
            }
        }
    }

    function playAt(index) {
        if (!rows.length || index < 0 || index >= rows.length) { return; }
        var row = rows[index];
        if (row.getAttribute('data-available') !== '1') {
            showToast('El archivo MP3 de «' + row.getAttribute('data-title') + '» todavía no está en la carpeta SongFiles.');
            return;
        }
        current = index;
        audio.src = row.getAttribute('data-src');
        updateNow(row);
        markActive();
        setPlayButton(true);
        timeNow.textContent = '0:00';
        timeTotal.textContent = '0:00';
        seek.value = 0;
        seek.style.setProperty('--pct', '0%');
        var promise = audio.play();
        if (promise && promise.catch) {
            promise.catch(function () { showToast('El navegador bloqueó la reproducción. Pulsa play de nuevo.'); });
        }
        registerPlay(row);
    }

    function next(step) {
        if (!rows.length) { return; }
        var index = current;
        if (shuffleOn) {
            index = Math.floor(Math.random() * rows.length);
        } else {
            index = (current < 0) ? 0 : (current + step + rows.length) % rows.length;
        }
        var attempts = 0;
        while (rows[index].getAttribute('data-available') !== '1' && attempts < rows.length) {
            index = (index + 1) % rows.length;
            attempts++;
        }
        if (attempts >= rows.length) { showToast('No hay pistas con archivo de audio disponible.'); return; }
        playAt(index);
    }

    function togglePlay() {
        if (current < 0) { playAt(0); return; }
        if (audio.paused) {
            var promise = audio.play();
            if (promise && promise.catch) { promise.catch(function () { }); }
            setPlayButton(true);
        } else {
            audio.pause();
            setPlayButton(false);
        }
    }

    function applyFilter() {
        var term = (search.value || '').toLowerCase().trim();
        var visible = 0;
        for (var i = 0; i < rows.length; i++) {
            var haystack = (rows[i].getAttribute('data-title') + ' ' +
                            rows[i].getAttribute('data-artist') + ' ' +
                            rows[i].getAttribute('data-album')).toLowerCase();
            var show = haystack.indexOf(term) !== -1;
            rows[i].style.display = show ? '' : 'none';
            if (show) { visible++; }
        }
        empty.hidden = visible !== 0;
        count.textContent = visible + (visible === 1 ? ' pista' : ' pistas');
    }

    function sortRows(mode) {
        var activeRow = current >= 0 ? rows[current] : null;
        var sorted = rows.slice();
        if (mode === 'top') {
            sorted.sort(function (a, b) {
                return (parseInt(b.getAttribute('data-plays'), 10) || 0) - (parseInt(a.getAttribute('data-plays'), 10) || 0);
            });
        } else if (mode === 'az') {
            sorted.sort(function (a, b) {
                return a.getAttribute('data-title').localeCompare(b.getAttribute('data-title'));
            });
        } else {
            sorted.sort(function (a, b) {
                return (parseInt(a.getAttribute('data-id'), 10) || 0) - (parseInt(b.getAttribute('data-id'), 10) || 0);
            });
        }
        for (var i = 0; i < sorted.length; i++) { list.appendChild(sorted[i]); }
        rows = sorted;
        current = activeRow ? rows.indexOf(activeRow) : -1;
        markActive();
        applyFilter();
    }

    function closestRow(element) {
        while (element && element !== list) {
            if (element.className && (' ' + element.className + ' ').indexOf(' pm-row ') !== -1) { return element; }
            element = element.parentNode;
        }
        return null;
    }

    /* --- Eventos --- */
    list.addEventListener('click', function (event) {
        var row = closestRow(event.target);
        if (row) { playAt(rows.indexOf(row)); }
    });

    list.addEventListener('keydown', function (event) {
        if (event.key === 'Enter') {
            var row = closestRow(event.target);
            if (row) { event.preventDefault(); playAt(rows.indexOf(row)); }
        }
    });

    if (search) { search.addEventListener('input', applyFilter); }

    var chips = document.querySelectorAll('.pm-chip');
    for (var c = 0; c < chips.length; c++) {
        chips[c].addEventListener('click', function () {
            for (var j = 0; j < chips.length; j++) { chips[j].className = 'pm-chip'; }
            this.className = 'pm-chip is-active';
            sortRows(this.getAttribute('data-sort'));
        });
    }

    byId('pmPlayAll').addEventListener('click', function () { next(1); });
    toggle.addEventListener('click', togglePlay);
    byId('pmPrev').addEventListener('click', function () { next(-1); });
    byId('pmNext').addEventListener('click', function () { next(1); });

    byId('pmShuffle').addEventListener('click', function () {
        shuffleOn = !shuffleOn;
        this.className = shuffleOn ? 'pm-ctrl is-active' : 'pm-ctrl';
        this.setAttribute('aria-pressed', shuffleOn ? 'true' : 'false');
        showToast(shuffleOn ? 'Reproducción aleatoria activada' : 'Reproducción aleatoria desactivada');
    });

    byId('pmRepeat').addEventListener('click', function () {
        repeatOn = !repeatOn;
        this.className = repeatOn ? 'pm-ctrl is-active' : 'pm-ctrl';
        this.setAttribute('aria-pressed', repeatOn ? 'true' : 'false');
        showToast(repeatOn ? 'Repetir canción activado' : 'Repetir canción desactivado');
    });

    byId('pmMute').addEventListener('click', function () {
        audio.muted = !audio.muted;
        this.className = audio.muted ? 'pm-ctrl is-active' : 'pm-ctrl';
    });

    byId('pmBannerClose').addEventListener('click', function () {
        byId('pmBanner').style.display = 'none';
    });

    audio.addEventListener('timeupdate', function () {
        var duration = audio.duration;
        timeNow.textContent = formatTime(audio.currentTime);
        if (isFinite(duration) && duration > 0) {
            var pct = (audio.currentTime / duration) * 100;
            seek.value = pct;
            seek.style.setProperty('--pct', pct + '%');
        }
    });

    audio.addEventListener('loadedmetadata', function () {
        timeTotal.textContent = formatTime(audio.duration);
    });

    audio.addEventListener('pause', function () { setPlayButton(false); });
    audio.addEventListener('play', function () { setPlayButton(true); });
    audio.addEventListener('error', function () {
        showToast('No se pudo cargar el archivo de audio de esta pista.');
    });

    audio.addEventListener('ended', function () {
        if (repeatOn) { playAt(current); } else { next(1); }
    });

    seek.addEventListener('input', function () {
        if (isFinite(audio.duration) && audio.duration > 0) {
            audio.currentTime = (parseFloat(seek.value) / 100) * audio.duration;
            seek.style.setProperty('--pct', seek.value + '%');
        }
    });

    volume.addEventListener('input', function () {
        audio.volume = parseFloat(volume.value);
        audio.muted = false;
        volume.style.setProperty('--vpct', (parseFloat(volume.value) * 100) + '%');
    });

    document.addEventListener('keydown', function (event) {
        var tag = (event.target.tagName || '').toLowerCase();
        if (tag === 'input' || tag === 'textarea' || tag === 'select') { return; }
        if (event.code === 'Space' || event.key === ' ') { event.preventDefault(); togglePlay(); }
        else if (event.key === 'ArrowRight') { next(1); }
        else if (event.key === 'ArrowLeft') { next(-1); }
    });

    audio.volume = parseFloat(volume.value);
    count.textContent = rows.length + (rows.length === 1 ? ' pista' : ' pistas');
    var featureValues = document.querySelectorAll('.pm-feature__value');
    if (featureValues.length >= 4) {
        byId('pmRailSongs').textContent = featureValues[0].textContent.trim();
        byId('pmRailArtists').textContent = featureValues[2].textContent.trim();
        byId('pmRailAlbums').textContent = featureValues[3].textContent.trim();
    }
    applyFilter();
}());
</script>

</asp:Content>
