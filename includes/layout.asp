<%
' =====================================================================
' PoliMusic - includes/layout.asp
' Estructura visual común: barra lateral, barra superior,
' reproductor fijo y scripts.
' =====================================================================

Function RenderHead(pageTitle)
    RenderHead = "" & _
    "<!DOCTYPE html>" & vbCrLf & _
    "<html lang=""es"">" & vbCrLf & _
    "<head>" & vbCrLf & _
    "<meta charset=""UTF-8"">" & vbCrLf & _
    "<meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">" & vbCrLf & _
    "<title>" & Html(pageTitle) & " | PoliMusic</title>" & vbCrLf & _
    "<link rel=""stylesheet"" href=""assets/css/style.css"">" & vbCrLf & _
    "</head>" & vbCrLf & _
    "<body>"
End Function

Function RenderSidebar(active)
    Dim navHome, navPlay, navAlbums, navArtists
    navHome = "nav-link" : navPlay = "nav-link" : navAlbums = "nav-link" : navArtists = "nav-link"
    Select Case LCase(active)
        Case "home":    navHome = navHome & " active"
        Case "playlists": navPlay = navPlay & " active"
        Case "albums":  navAlbums = navAlbums & " active"
        Case "artists": navArtists = navArtists & " active"
    End Select

    Dim adminSection
    adminSection = ""
    If IsAdmin() Then
        adminSection = "" & _
        "<div class=""nav-section"">Administración</div>" & vbCrLf & _
        "<a class=""nav-link"" href=""users.asp"">" & Icon("users", 18) & "<span>Usuarios</span></a>" & vbCrLf & _
        "<a class=""nav-link"" href=""song_form.asp"">" & Icon("plus", 18) & "<span>Nueva canción</span></a>" & vbCrLf & _
        "<a class=""nav-link"" href=""playlist_form.asp"">" & Icon("plus", 18) & "<span>Nueva lista</span></a>" & vbCrLf & _
        "<a class=""nav-link"" href=""artist_form.asp"">" & Icon("plus", 18) & "<span>Nuevo artista</span></a>" & vbCrLf & _
        "<a class=""nav-link"" href=""album_form.asp"">" & Icon("plus", 18) & "<span>Nuevo álbum</span></a>"
    End If

    Dim roleChip
    If IsAdmin() Then roleChip = "chip chip-admin" Else roleChip = "chip chip-user"

    RenderSidebar = "" & _
    "<aside class=""sidebar"" id=""sidebar"">" & vbCrLf & _
    "  <div class=""sidebar-head"">" & vbCrLf & _
    "    <a href=""index.asp"" class=""brand"">" & vbCrLf & _
    "      <span class=""brand-mark"">" & Icon("song", 20) & "</span>" & vbCrLf & _
    "      <span class=""brand-name"">Poli<em>Music</em></span>" & vbCrLf & _
    "    </a>" & vbCrLf & _
    "    <button class=""icon-btn sidebar-close"" id=""sidebarClose"" type=""button"" aria-label=""Cerrar menú"">" & Icon("close", 20) & "</button>" & vbCrLf & _
    "  </div>" & vbCrLf & _
    "  <nav class=""nav"">" & vbCrLf & _
    "    <a class=""" & navHome & """ href=""index.asp"">" & Icon("home", 18) & "<span>Inicio</span></a>" & vbCrLf & _
    "    <a class=""" & navPlay & """ href=""playlists.asp"">" & Icon("playlist", 18) & "<span>Listas de reproducción</span></a>" & vbCrLf & _
    "    <a class=""" & navAlbums & """ href=""albums.asp"">" & Icon("album", 18) & "<span>Álbumes</span></a>" & vbCrLf & _
    "    <a class=""" & navArtists & """ href=""artists.asp"">" & Icon("artist", 18) & "<span>Artistas</span></a>" & vbCrLf & _
    adminSection & vbCrLf & _
    "  </nav>" & vbCrLf & _
    "  <div class=""sidebar-foot"">" & vbCrLf & _
    "    <div class=""user-card"">" & vbCrLf & _
    "      <img class=""avatar"" src=""" & UserPhotoUrl(CurrentUserPhoto()) & """ alt=""Foto de perfil""" & ImgFallback(USER_PHOTOS_FOLDER & DEFAULT_USER_PHOTO) & ">" & vbCrLf & _
    "      <div class=""user-meta"">" & vbCrLf & _
    "        <div class=""user-name"" title=""" & Html(CurrentUsername()) & """>" & Html(CurrentUsername()) & "</div>" & vbCrLf & _
    "        <div class=""user-role""><span class=""" & roleChip & """></span>" & Html(RoleName(Session("USER_TYPE"))) & "</div>" & vbCrLf & _
    "      </div>" & vbCrLf & _
    "    </div>" & vbCrLf & _
    "    <a href=""logout.asp"" class=""btn btn-ghost btn-block"">" & Icon("logout", 18) & "<span>Cerrar sesión</span></a>" & vbCrLf & _
    "  </div>" & vbCrLf & _
    "</aside>" & vbCrLf & _
    "<div class=""sidebar-backdrop"" id=""sidebarBackdrop""></div>"
End Function

Function RenderShellOpen(active, pageTitle, pageSubtitle, actionsHtml)
    If IsEmpty(actionsHtml) Then actionsHtml = ""
    RenderShellOpen = "" & _
    "<div class=""app"">" & vbCrLf & _
    RenderSidebar(active) & vbCrLf & _
    "<div class=""main"">" & vbCrLf & _
    "  <header class=""topbar"">" & vbCrLf & _
    "    <button class=""icon-btn menu-toggle"" id=""menuToggle"" type=""button"" aria-label=""Abrir menú"">" & Icon("menu", 22) & "</button>" & vbCrLf & _
    "    <div class=""topbar-title"">" & vbCrLf & _
    "      <h1>" & Html(pageTitle) & "</h1>" & vbCrLf & _
    "      <p>" & Html(pageSubtitle) & "</p>" & vbCrLf & _
    "    </div>" & vbCrLf & _
    "    <div class=""topbar-actions"">" & actionsHtml & "</div>" & vbCrLf & _
    "  </header>" & vbCrLf & _
    "  <main class=""content"">"
End Function

Function RenderShellClose()
    RenderShellClose = "" & _
    "  </main>" & vbCrLf & _
    "  <footer class=""site-footer"">PoliMusic &middot; Proyecto académico ASP clásico</footer>" & vbCrLf & _
    "</div>" & vbCrLf & _
    "</div>" & vbCrLf & _
    RenderPlayerBar() & vbCrLf & _
    "<div class=""toast-wrap"" id=""toastWrap"" aria-live=""polite""></div>" & vbCrLf & _
    "<script src=""assets/js/app.js""></script>" & vbCrLf & _
    "</body>" & vbCrLf & _
    "</html>"
End Function

Function RenderPlayerBar()
    RenderPlayerBar = "" & _
    "<section class=""player"" id=""player"" aria-label=""Reproductor de audio"">" & vbCrLf & _
    "  <div class=""player-track"">" & vbCrLf & _
    "    <div class=""player-cover"" id=""pmCover"">" & Icon("music", 22) & "</div>" & vbCrLf & _
    "    <div class=""player-meta"">" & vbCrLf & _
    "      <div class=""player-title"" id=""pmTitle"">Sin reproducción</div>" & vbCrLf & _
    "      <div class=""player-artist"" id=""pmArtist"">Selecciona una canción</div>" & vbCrLf & _
    "    </div>" & vbCrLf & _
    "  </div>" & vbCrLf & _
    "  <div class=""player-center"">" & vbCrLf & _
    "    <div class=""player-controls"">" & vbCrLf & _
    "      <button class=""ctl-btn"" id=""pmPrev"" type=""button"" title=""Anterior"" aria-label=""Anterior"">" & Icon("prev", 20) & "</button>" & vbCrLf & _
    "      <button class=""ctl-btn ctl-main"" id=""pmToggle"" type=""button"" title=""Reproducir/Pausar"" aria-label=""Reproducir"">" & Icon("play", 22) & "</button>" & vbCrLf & _
    "      <button class=""ctl-btn"" id=""pmNext"" type=""button"" title=""Siguiente"" aria-label=""Siguiente"">" & Icon("next", 20) & "</button>" & vbCrLf & _
    "    </div>" & vbCrLf & _
    "    <div class=""player-progress"">" & vbCrLf & _
    "      <span class=""time"" id=""pmCurrent"">0:00</span>" & vbCrLf & _
    "      <input type=""range"" id=""pmSeek"" min=""0"" max=""100"" value=""0"" step=""0.1"" aria-label=""Progreso"">" & vbCrLf & _
    "      <span class=""time"" id=""pmDuration"">0:00</span>" & vbCrLf & _
    "    </div>" & vbCrLf & _
    "  </div>" & vbCrLf & _
    "  <div class=""player-right"">" & vbCrLf & _
    "    <span class=""vol-icon"">" & Icon("volume", 18) & "</span>" & vbCrLf & _
    "    <input type=""range"" id=""pmVolume"" min=""0"" max=""1"" value=""0.8"" step=""0.01"" aria-label=""Volumen"">" & vbCrLf & _
    "  </div>" & vbCrLf & _
    "</section>" & vbCrLf & _
    "<audio id=""pmAudio"" preload=""none""></audio>"
End Function
%>
