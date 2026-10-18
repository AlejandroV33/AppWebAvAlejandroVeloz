<%
' =====================================================================
' PoliMusic - artists.asp
' Catálogo de artistas (TBL_ARTIST) con sus canciones (TBL_PLAYER).
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/layout.asp"-->
<%
RequireLogin

Dim db, rs, actions
Set db = DB()
Set rs = db.Recordset( _
    "SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
    "       (SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS SONG_COUNT " & _
    "FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME")

actions = ""
If IsAdmin() Then
    actions = "<a class=""btn btn-primary"" href=""artist_form.asp"">" & Icon("plus", 16) & "<span>Nuevo artista</span></a>"
End If
%>
<%= RenderHead("Artistas") %>
<%= RenderShellOpen("artists", "Artistas", "Explora y gestiona los artistas", actions) %>

<%= RenderFlash() %>

<% If rs.EOF Then %>
<div class="table-wrap" style="padding:42px 20px;text-align:center;color:var(--text-mute)">
    No hay artistas registrados.
    <% If IsAdmin() Then %>Crea el primero con el botón «Nuevo artista».<% End If %>
</div>
<% Else %>
<div class="playlist-grid">
<%
Do While Not rs.EOF
    Dim aId, aName, aLast, aImg, aCount
    aId    = rs.Fields("ID_ARTIST").Value
    aName  = rs.Fields("ARTIST_NAME").Value
    aLast  = rs.Fields("ARTIST_LASTNAME").Value
    aImg   = rs.Fields("ARTIST_IMAGE").Value
    aCount = rs.Fields("SONG_COUNT").Value
%>
    <div class="playlist-card">
        <div class="playlist-cover" style="display:grid;place-items:center;background:linear-gradient(135deg,var(--bg-4),var(--bg-3))">
            <div class="cover-art cover-art--song" style="width:72px;height:72px;border-radius:50%"><%= Icon("artist", 30) %></div>
        </div>
        <div class="playlist-name"><%= Html(aName) %><% If Not IsNull(aLast) And aLast <> "" Then %> <%= Html(aLast) %><% End If %></div>
        <div class="playlist-meta" style="margin-top:10px">
            <span><%= aCount %> canciones</span>
            <span class="card-admin-actions">
                <% If IsAdmin() Then %>
                <a class="icon-btn" href="artist_form.asp?id=<%= aId %>" title="Editar artista"><%= Icon("edit", 17) %></a>
                <form class="inline-form" method="post" action="artist_delete.asp" data-confirm="¿Eliminar al artista '<%= Replace(Html(aName), "'", "") %>'? También se quitará de sus canciones.">
                    <input type="hidden" name="id" value="<%= aId %>">
                    <button class="icon-btn icon-btn--danger" type="submit" title="Eliminar artista"><%= Icon("trash", 17) %></button>
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
