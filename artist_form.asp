<%
' =====================================================================
' PoliMusic - artist_form.asp  (SOLO ADMINISTRADORES)
' Crear / editar un artista (TBL_ARTIST).
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

Dim fName, fLast, fImg
fName = "" : fLast = "" : fImg = ""

Dim db
Set db = OpenPoliDB()

If isEdit Then
    Dim rs
    Set rs = db.Recordset("SELECT ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(Array("id", editId)))
    If rs.EOF Then
        SetFlash "error", "El artista no existe."
        RedirectTo "artists.asp"
    End If
    fName = rs.Fields("ARTIST_NAME").Value
    If Not IsNull(rs.Fields("ARTIST_LASTNAME").Value) Then fLast = rs.Fields("ARTIST_LASTNAME").Value
    If Not IsNull(rs.Fields("ARTIST_IMAGE").Value) Then fImg = rs.Fields("ARTIST_IMAGE").Value
    rs.Close
    Set rs = Nothing
End If
Set db = Nothing
%>
<%= RenderHead(IIf(isEdit, "Editar artista", "Nuevo artista")) %>
<%= RenderShellOpen("artists", IIf(isEdit, "Editar artista", "Nuevo artista"), "Gestión de artistas", "") %>

<%= RenderFlash() %>

<div class="form-card">
    <form method="post" action="artist_save.asp">
        <input type="hidden" name="id" value="<%= editId %>">
        <div class="form-grid">
            <div class="field">
                <label for="name">Nombre <span class="req">*</span></label>
                <input type="text" id="name" name="name" maxlength="100" required value="<%= Html(fName) %>">
            </div>
            <div class="field">
                <label for="lastname">Apellido</label>
                <input type="text" id="lastname" name="lastname" maxlength="100" value="<%= Html(fLast) %>">
            </div>
            <div class="field full">
                <label for="image">Imagen</label>
                <input type="text" id="image" name="image" maxlength="255" value="<%= Html(fImg) %>" placeholder="~/ArtistImages/artista.jpg">
                <div class="hint">Ruta como en la BD (opcional). Si el archivo no existe, se muestra un avatar genérico.</div>
            </div>
        </div>
        <div class="form-actions">
            <button type="submit" class="btn btn-primary"><%= Icon("plus", 16) %> <%= IIf(isEdit, "Guardar cambios", "Crear artista") %></button>
            <a class="btn btn-ghost" href="artists.asp">Cancelar</a>
        </div>
    </form>
</div>

<%= RenderShellClose() %>
