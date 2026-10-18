<%
' =====================================================================
' PoliMusic - album_form.asp  (SOLO ADMINISTRADORES)
' Crear / editar un álbum (TBL_ALBUM).
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/layout.asp"-->
<%
RequireAdmin

Dim editId, isEdit
editId = Request.QueryString("id")
isEdit = False
If IsNumeric(editId) And CLng(editId) > 0 Then
    editId = CLng(editId)
    isEdit = True
Else
    editId = 0
End If

Dim fTitle, fYear, fImg
fTitle = "" : fYear = "" : fImg = ""

Dim db
Set db = DB()

If isEdit Then
    Dim rs
    Set rs = db.Recordset("SELECT TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(Array("id", editId)))
    If rs.EOF Then
        SetFlash "error", "El álbum no existe."
        RedirectTo "albums.asp"
    End If
    fTitle = rs.Fields("TITLE_ALBUM").Value
    If Not IsNull(rs.Fields("RELEASE_YEAR").Value) Then fYear = CStr(rs.Fields("RELEASE_YEAR").Value)
    If Not IsNull(rs.Fields("ALBUM_IMAGE_PATH").Value) Then fImg = rs.Fields("ALBUM_IMAGE_PATH").Value
    rs.Close
    Set rs = Nothing
End If
Set db = Nothing
%>
<%= RenderHead(IIf(isEdit, "Editar álbum", "Nuevo álbum")) %>
<%= RenderShellOpen("albums", IIf(isEdit, "Editar álbum", "Nuevo álbum"), "Gestión de álbumes", "") %>

<%= RenderFlash() %>

<div class="form-card">
    <form method="post" action="album_save.asp">
        <input type="hidden" name="id" value="<%= editId %>">
        <div class="form-grid">
            <div class="field">
                <label for="title">Título del álbum <span class="req">*</span></label>
                <input type="text" id="title" name="title" maxlength="50" required value="<%= Html(fTitle) %>">
            </div>
            <div class="field">
                <label for="year">Año de lanzamiento</label>
                <input type="number" id="year" name="year" min="1900" max="2100" value="<%= Html(fYear) %>" placeholder="2000">
            </div>
            <div class="field full">
                <label for="image">Imagen</label>
                <input type="text" id="image" name="image" maxlength="255" value="<%= Html(fImg) %>" placeholder="~/albumImages/album1.png">
                <div class="hint">Ruta como en la BD (opcional). El proyecto incluye las carpetas <code>UserImages/</code>, <code>PlaylistImages/</code> y <code>SongFiles/</code>; si no existe la imagen se muestra un disco genérico.</div>
            </div>
        </div>
        <div class="form-actions">
            <button type="submit" class="btn btn-primary"><%= Icon("plus", 16) %> <%= IIf(isEdit, "Guardar cambios", "Crear álbum") %></button>
            <a class="btn btn-ghost" href="albums.asp">Cancelar</a>
        </div>
    </form>
</div>

<%= RenderShellClose() %>
