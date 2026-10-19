<%
' =====================================================================
' PoliMusic - index.asp
' Pantalla principal: mensaje de bienvenida + listado de canciones
' (Song List) con reproductor de audio HTML5.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/layout.asp"-->
<%
RequireLogin

Dim db, rs, totalSongs, actions, roleClass, emptyColspan
Dim i, vId, vName, vPath, vPlays, vArtists, vAlbums, artistLabel, albumLabel
Set db = OpenPoliDB()
Set rs = db.Recordset( _
    "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS, 0) AS PLAYS, " & _
    "       STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
    "              FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
    "              WHERE p.ID_SONG = s.ID_SONG FOR XML PATH('')), 1, 2, '') AS ARTISTS, " & _
    "       STUFF((SELECT ', ' + al.TITLE_ALBUM " & _
    "              FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
    "              WHERE t.ID_SONG = s.ID_SONG FOR XML PATH('')), 1, 2, '') AS ALBUMS " & _
    "FROM TBL_SONG s ORDER BY s.ID_SONG", Nothing)
totalSongs = db.Scalar("SELECT COUNT(*) FROM TBL_SONG", Nothing)

actions = "<div class=""search-box"">" & Icon("search", 16) & _
          "<input type=""search"" id=""songSearch"" placeholder=""Buscar canción o artista..."" aria-label=""Buscar""></div>"
If IsAdmin() Then
    actions = actions & "<a class=""btn btn-primary"" href=""song_form.asp"">" & Icon("plus", 16) & "<span>Nueva canción</span></a>"
End If
actions = actions & "<button class=""btn btn-ghost"" type=""button"" id=""playAllBtn"">" & Icon("play", 16) & "<span>Reproducir todo</span></button>"
If IsAdmin() Then
    roleClass = "chip chip-admin"
    emptyColspan = 7
Else
    roleClass = "chip chip-user"
    emptyColspan = 6
End If
%>
<%= RenderHead("Inicio") %>
<%= RenderShellOpen("home", "Inicio", "Tu música, en cualquier momento", actions) %>

<%= RenderFlash() %>

<section class="welcome">
    <div class="welcome-eyebrow"><%= Icon("music", 14) %> PoliMusic</div>
    <h2>¡Bienvenido, <%= Html(CurrentUsername()) %>!</h2>
    <p>
        Has iniciado sesión como <strong><%= Html(Session("EMAIL")) %></strong>.
        Explora el catálogo, abre tus listas de reproducción y disfruta de la música.
        <% If IsAdmin() Then %>Como administrador puedes gestionar usuarios, canciones, listas, artistas y álbumes.<% End If %>
    </p>
    <div class="welcome-chips">
        <span class="<%= roleClass %>"><%= Html(RoleName(Session("USER_TYPE"))) %></span>
        <span class="chip"><%= totalSongs %> canciones en el catálogo</span>
        <span class="chip">Reproductor integrado</span>
    </div>
</section>

<div class="song-list-intro">
    <h2>A continuación, se presenta el listado de canciones (Song List)</h2>
    <p><span id="songCount"><%= totalSongs %> canciones</span> &middot; haz clic en el botón de reproducción de cualquier fila para escucharla.</p>
</div>

<div class="table-wrap">
    <div class="table-scroll">
        <table class="data-table">
            <thead>
                <tr>
                    <th class="col-index">#</th>
                    <th>Canción</th>
                    <th>Artista</th>
                    <th>Álbum</th>
                    <th>Reproducciones</th>
                    <% If IsAdmin() Then %><th style="text-align:right">Acciones</th><% End If %>
                </tr>
            </thead>
            <tbody>
            <%
            i = 0
            Do While Not rs.EOF
                i = i + 1
                vId      = rs.Fields("ID_SONG").Value
                vName    = rs.Fields("SONG_NAME").Value
                vPath    = rs.Fields("SONG_PATH").Value
                vPlays   = rs.Fields("PLAYS").Value
                vArtists = rs.Fields("ARTISTS").Value
                vAlbums  = rs.Fields("ALBUMS").Value
                If IsNull(vArtists) Then artistLabel = "—" Else artistLabel = Html(vArtists)
                If IsNull(vAlbums) Then albumLabel = "—" Else albumLabel = Html(vAlbums)
            %>
                <tr data-id="<%= vId %>" data-file="<%= Html(SongFileUrl(vPath)) %>" data-title="<%= Html(vName) %>" data-artist="<%= Html(vArtists) %>">
                    <td class="col-index">
                        <span class="col-num"><%= i %></span>
                        <button class="row-play" type="button" title="Reproducir" aria-label="Reproducir"><%= Icon("play", 13) %></button>
                    </td>
                    <td>
                        <div class="song-cell">
                            <div class="cover-art cover-art--song"><%= Icon("music", 20) %></div>
                            <div>
                                <div class="song-title"><%= Html(vName) %></div>
                                <div class="song-sub"><%= Html(BaseName(vPath)) %></div>
                            </div>
                        </div>
                    </td>
                    <td class="cell-dim"><%= artistLabel %></td>
                    <td class="cell-dim"><%= albumLabel %></td>
                    <td><span class="chip"><%= Icon("plays", 12) %> <%= CLng(vPlays) %></span></td>
                    <% If IsAdmin() Then %>
                    <td>
                        <div class="row-actions">
                            <a class="icon-btn" href="song_form.asp?id=<%= vId %>" title="Editar canción"><%= Icon("edit", 17) %></a>
                            <form class="inline-form" method="post" action="song_delete.asp" data-confirm="¿Eliminar la canción '<%= Replace(Html(vName), "'", "") %>'? Esta acción no se puede deshacer.">
                                <input type="hidden" name="id" value="<%= vId %>">
                                <button class="icon-btn icon-btn--danger" type="submit" title="Eliminar canción"><%= Icon("trash", 17) %></button>
                            </form>
                        </div>
                    </td>
                    <% End If %>
                </tr>
            <%
                rs.MoveNext
            Loop
            %>
            <% If totalSongs = 0 Then %>
                <tr class="empty-row">
                    <td colspan="<%= emptyColspan %>">
                        No hay canciones registradas todavía.
                        <% If IsAdmin() Then %>Usa el botón «Nueva canción» para agregar la primera.<% End If %>
                    </td>
                </tr>
            <% End If %>
            </tbody>
        </table>
    </div>
</div>

<%= RenderShellClose() %>
<%
rs.Close
Set rs = Nothing
Set db = Nothing
%>
