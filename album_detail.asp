<%
' =====================================================================
' PoliMusic - album_detail.asp
' Detalle de un álbum con sus canciones (TBL_TRACKLIST).
' Los administradores pueden agregar y quitar canciones.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/layout.asp"-->
<%
RequireLogin

Dim albumId
albumId = Request.QueryString("id")
If IsNumeric(albumId) Then albumId = CLng(albumId) Else albumId = 0

Dim db, rs
Set db = OpenPoliDB()

Dim alTitle
alTitle = db.Scalar("SELECT TITLE_ALBUM FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(Array("id", albumId)))
If IsNull(alTitle) Then
    SetFlash "error", "El álbum no existe."
    RedirectTo "albums.asp"
End If
Dim alYear, alCount
alYear = db.Scalar("SELECT RELEASE_YEAR FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(Array("id", albumId)))
alCount = db.Scalar("SELECT COUNT(*) FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(Array("id", albumId)))

Set rs = db.Recordset( _
    "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS,0) AS PLAYS, " & _
    "       STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
    "              FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
    "              WHERE p.ID_SONG = s.ID_SONG FOR XML PATH('')), 1, 2, '') AS ARTISTS " & _
    "FROM TBL_TRACKLIST t INNER JOIN TBL_SONG s ON s.ID_SONG = t.ID_SONG " & _
    "WHERE t.ID_ALBUM = ? ORDER BY s.ID_SONG", Array(Array("id", albumId)))

Dim rsAdd
Set rsAdd = db.Recordset( _
    "SELECT ID_SONG, SONG_NAME FROM TBL_SONG " & _
    "WHERE ID_SONG NOT IN (SELECT ID_SONG FROM TBL_TRACKLIST WHERE ID_ALBUM = ?) " & _
    "ORDER BY SONG_NAME", Array(Array("id", albumId)))

Dim actions
actions = "<button class=""btn btn-ghost"" type=""button"" id=""playAllBtn"">" & Icon("play", 16) & "<span>Reproducir todo</span></button>"
If IsAdmin() Then
    actions = actions & "<a class=""btn btn-ghost"" href=""album_form.asp?id=" & albumId & """>" & Icon("edit", 16) & "<span>Editar álbum</span></a>"
End If
%>
<%= RenderHead(alTitle) %>
<%= RenderShellOpen("albums", alTitle, "Álbum", actions) %>

<%= RenderFlash() %>

<section class="playlist-hero">
    <div class="cover-frame">
        <div class="cover-art cover-art--lg"><%= Icon("album", 56) %></div>
    </div>
    <div class="meta">
        <div class="song-list-intro" style="margin:0 0 12px;padding:8px 14px">
            <span style="font-size:12px;font-weight:700;letter-spacing:1.2px;text-transform:uppercase;color:var(--accent)">Álbum</span>
        </div>
        <h2><%= Html(alTitle) %></h2>
        <div class="stats" style="display:flex;gap:18px;color:var(--text-mute);font-size:13px;flex-wrap:wrap">
            <span>Año: <b style="color:var(--text)"><%= IIf(IsNull(alYear), "—", CStr(alYear)) %></b></span>
            <span><b style="color:var(--text)"><%= alCount %></b> canciones</span>
        </div>
    </div>
</section>

<% If IsAdmin() And Not rsAdd.EOF Then %>
<div class="form-card" style="max-width:none;margin-bottom:22px;padding:18px 20px">
    <form method="post" action="album_song_add.asp" class="form-grid" style="align-items:end">
        <input type="hidden" name="album_id" value="<%= albumId %>">
        <div class="field">
            <label for="song_id">Agregar canción al álbum</label>
            <select id="song_id" name="song_id" required>
                <option value="">-- Selecciona una canción --</option>
                <% Do While Not rsAdd.EOF %>
                <option value="<%= rsAdd.Fields("ID_SONG").Value %>"><%= Html(rsAdd.Fields("SONG_NAME").Value) %></option>
                <% rsAdd.MoveNext : Loop %>
            </select>
        </div>
        <div class="field">
            <button type="submit" class="btn btn-primary"><%= Icon("plus", 16) %> Agregar</button>
        </div>
    </form>
</div>
<% End If %>

<div class="song-list-intro">
    <h2>Canciones del álbum «<%= Html(alTitle) %>»</h2>
    <p><%= alCount %> canciones &middot; reproducibles desde el reproductor inferior.</p>
</div>

<div class="table-wrap">
    <div class="table-scroll">
        <table class="data-table">
            <thead>
                <tr>
                    <th class="col-index">#</th>
                    <th>Canción</th>
                    <th>Artista</th>
                    <th>Reproducciones</th>
                    <% If IsAdmin() Then %><th style="text-align:right">Acciones</th><% End If %>
                </tr>
            </thead>
            <tbody>
            <%
            Dim i : i = 0
            Do While Not rs.EOF
                i = i + 1
                Dim vId, vName, vPath, vPlays, vArtists
                vId      = rs.Fields("ID_SONG").Value
                vName    = rs.Fields("SONG_NAME").Value
                vPath    = rs.Fields("SONG_PATH").Value
                vPlays   = rs.Fields("PLAYS").Value
                vArtists = rs.Fields("ARTISTS").Value
            %>
                <tr data-id="<%= vId %>" data-file="<%= Html(SongFileUrl(vPath)) %>" data-title="<%= Html(vName) %>" data-artist="<%= Html(vArtists) %>">
                    <td class="col-index">
                        <span class="col-num"><%= i %></span>
                        <button class="row-play" type="button" title="Reproducir" aria-label="Reproducir"><%= Icon("play", 13) %></button>
                    </td>
                    <td>
                        <div class="song-cell">
                            <div class="cover-art cover-art--song"><%= Icon("music", 20) %></div>
                            <div><div class="song-title"><%= Html(vName) %></div></div>
                        </div>
                    </td>
                    <td class="cell-dim"><%= IIf(IsNull(vArtists), "—", Html(vArtists)) %></td>
                    <td><span class="chip"><%= Icon("plays", 12) %> <%= CLng(vPlays) %></span></td>
                    <% If IsAdmin() Then %>
                    <td>
                        <div class="row-actions">
                            <form class="inline-form" method="post" action="album_song_remove.asp" data-confirm="¿Quitar '<%= Replace(Html(vName), "'", "") %>' del álbum?">
                                <input type="hidden" name="song_id" value="<%= vId %>">
                                <input type="hidden" name="album_id" value="<%= albumId %>">
                                <button class="icon-btn icon-btn--danger" type="submit" title="Quitar del álbum"><%= Icon("remove", 17) %></button>
                            </form>
                        </div>
                    </td>
                    <% End If %>
                </tr>
            <%
                rs.MoveNext
            Loop
            %>
            <% If alCount = 0 Then %>
                <tr class="empty-row">
                    <td colspan="<%= IIf(IsAdmin(), 6, 5) %>">
                        Este álbum no tiene canciones todavía.
                        <% If IsAdmin() Then %>Agrega la primera con el selector de arriba.<% End If %>
                    </td>
                </tr>
            <% End If %>
            </tbody>
        </table>
    </div>
</div>

<%= RenderShellClose() %>
<%
rs.Close : Set rs = Nothing
rsAdd.Close : Set rsAdd = Nothing
Set db = Nothing
%>
