<%
' =====================================================================
' PoliMusic - playlists.asp
' Catálogo de listas de reproducción (TBL_PLAYLIST).
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/layout.asp"-->
<%
RequireLogin

Dim db, rs, actions
Set db = OpenPoliDB()
Set rs = db.Recordset( _
    "SELECT p.ID_PLAYLIST, p.TITLE, p.TYPE, p.PHOTO, u.USERNAME, " & _
    "       (SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONG_COUNT " & _
    "FROM TBL_PLAYLIST p INNER JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
    "ORDER BY p.CREATION_DATE DESC", Nothing)

actions = ""
If IsAdmin() Then
    actions = "<a class=""btn btn-primary"" href=""playlist_form.asp"">" & Icon("plus", 16) & "<span>Nueva lista</span></a>"
End If
%>
<%= RenderHead("Listas de reproducción") %>
<%= RenderShellOpen("playlists", "Listas de reproducción", "Explora y gestiona tus listas", actions) %>

<%= RenderFlash() %>

<% If rs.EOF Then %>
<div class="table-wrap" style="padding:42px 20px;text-align:center;color:var(--text-mute)">
    No hay listas de reproducción registradas.
    <% If IsAdmin() Then %>Crea la primera con el botón «Nueva lista».<% End If %>
</div>
<% Else %>
<div class="playlist-grid">
<%
Do While Not rs.EOF
    Dim pId, pTitle, pType, pPhoto, pOwner, pCount
    pId    = rs.Fields("ID_PLAYLIST").Value
    pTitle = rs.Fields("TITLE").Value
    pType  = rs.Fields("TYPE").Value
    pPhoto = rs.Fields("PHOTO").Value
    pOwner = rs.Fields("USERNAME").Value
    pCount = rs.Fields("SONG_COUNT").Value
%>
    <div class="playlist-card" data-href="playlist_detail.asp?id=<%= pId %>">
        <div class="playlist-cover">
            <img src="<%= PlaylistPhotoUrl(pPhoto) %>" alt="Portada de <%= Html(pTitle) %>"<%= ImgFallback(PLAYLIST_PHOTOS_FOLDER & DEFAULT_PLAYLIST_PHOTO) %>>
            <button class="play-fab" type="button" title="Abrir y reproducir" aria-label="Abrir y reproducir"><%= Icon("play", 18) %></button>
        </div>
        <div class="playlist-name"><%= Html(pTitle) %></div>
        <div class="playlist-meta" style="margin-top:10px">
            <span><%= PlaylistTypeName(pType) %> &middot; <%= pCount %> canciones</span>
            <span class="card-admin-actions">
                <a class="icon-btn" href="playlist_detail.asp?id=<%= pId %>" title="Ver lista"><%= Icon("eye", 17) %></a>
                <% If IsAdmin() Then %>
                <a class="icon-btn" href="playlist_form.asp?id=<%= pId %>" title="Editar lista"><%= Icon("edit", 17) %></a>
                <form class="inline-form" method="post" action="playlist_delete.asp" data-confirm="¿Eliminar la lista '<%= Replace(Html(pTitle), "'", "") %>' y todas sus canciones asociadas?">
                    <input type="hidden" name="id" value="<%= pId %>">
                    <button class="icon-btn icon-btn--danger" type="submit" title="Eliminar lista"><%= Icon("trash", 17) %></button>
                </form>
                <% End If %>
            </span>
        </div>
    </div>
<%
    rs.MoveNext
Loop
%>
</div>
<% End If %>

<%= RenderShellClose() %>
<%
rs.Close
Set rs = Nothing
Set db = Nothing
%>
