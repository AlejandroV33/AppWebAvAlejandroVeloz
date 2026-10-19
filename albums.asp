<%
' =====================================================================
' PoliMusic - albums.asp
' Catálogo de álbumes (TBL_ALBUM).
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
    "SELECT al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
    "       (SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS SONG_COUNT " & _
    "FROM TBL_ALBUM al ORDER BY al.TITLE_ALBUM", Nothing)

actions = ""
If IsAdmin() Then
    actions = "<a class=""btn btn-primary"" href=""album_form.asp"">" & Icon("plus", 16) & "<span>Nuevo álbum</span></a>"
End If
%>
<%= RenderHead("Álbumes") %>
<%= RenderShellOpen("albums", "Álbumes", "Explora y gestiona los álbumes", actions) %>

<%= RenderFlash() %>

<% If rs.EOF Then %>
<div class="table-wrap" style="padding:42px 20px;text-align:center;color:var(--text-mute)">
    No hay álbumes registrados.
    <% If IsAdmin() Then %>Crea el primero con el botón «Nuevo álbum».<% End If %>
</div>
<% Else %>
<div class="playlist-grid">
<%
Do While Not rs.EOF
    Dim alId, alTitle, alYear, alImg, alCount
    alId    = rs.Fields("ID_ALBUM").Value
    alTitle = rs.Fields("TITLE_ALBUM").Value
    alYear  = rs.Fields("RELEASE_YEAR").Value
    alImg   = rs.Fields("ALBUM_IMAGE_PATH").Value
    alCount = rs.Fields("SONG_COUNT").Value
%>
    <div class="playlist-card" data-href="album_detail.asp?id=<%= alId %>">
        <div class="playlist-cover" style="position:relative;background:linear-gradient(135deg,var(--bg-4),var(--bg-3));display:grid;place-items:center">
            <div class="cover-art cover-art--song" style="width:88px;height:88px"><%= Icon("album", 36) %></div>
            <button class="play-fab" type="button" title="Ver álbum" aria-label="Ver álbum"><%= Icon("eye", 18) %></button>
        </div>
        <div class="playlist-name"><%= Html(alTitle) %></div>
        <div class="playlist-meta" style="margin-top:10px">
            <span><%= IIf(IsNull(alYear), "—", CStr(alYear)) %> &middot; <%= alCount %> canciones</span>
            <span class="card-admin-actions">
                <a class="icon-btn" href="album_detail.asp?id=<%= alId %>" title="Ver álbum"><%= Icon("eye", 17) %></a>
                <% If IsAdmin() Then %>
                <a class="icon-btn" href="album_form.asp?id=<%= alId %>" title="Editar álbum"><%= Icon("edit", 17) %></a>
                <form class="inline-form" method="post" action="album_delete.asp" data-confirm="¿Eliminar el álbum '<%= Replace(Html(alTitle), "'", "") %>' y todas sus canciones asociadas?">
                    <input type="hidden" name="id" value="<%= alId %>">
                    <button class="icon-btn icon-btn--danger" type="submit" title="Eliminar álbum"><%= Icon("trash", 17) %></button>
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
