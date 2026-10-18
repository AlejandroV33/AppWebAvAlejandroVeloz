<%
' =====================================================================
' PoliMusic - user_form.asp  (SOLO ADMINISTRADORES)
' Crear / editar un usuario (TBL_USER).
' Las contraseñas nuevas/actualizadas se guardan con hash SHA-1.
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

Dim fName, fEmail, fBirth, fPhoto, fType
fName = "" : fEmail = "" : fBirth = "" : fPhoto = "" : fType = 0

Dim db
Set db = DB()

If isEdit Then
    Dim rs
    Set rs = db.Recordset("SELECT USERNAME, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE FROM TBL_USER WHERE ID_USER = ?", Array(Array("id", editId)))
    If rs.EOF Then
        SetFlash "error", "El usuario no existe."
        RedirectTo "users.asp"
    End If
    fName  = rs.Fields("USERNAME").Value
    fEmail = rs.Fields("EMAIL").Value
    If Not IsNull(rs.Fields("BIRTHDAY").Value) Then fBirth = CStr(FormatDateTime(rs.Fields("BIRTHDAY").Value, vbShortDate))
    fPhoto = rs.Fields("USER_PHOTO").Value
    fType  = rs.Fields("USER_TYPE").Value
    rs.Close
    Set rs = Nothing
End If
Set db = Nothing
%>
<%= RenderHead(IIf(isEdit, "Editar usuario", "Nuevo usuario")) %>
<%= RenderShellOpen("users", IIf(isEdit, "Editar usuario", "Nuevo usuario"), "Gestión de usuarios", "") %>

<%= RenderFlash() %>

<div class="form-card">
    <form method="post" action="user_save.asp">
        <input type="hidden" name="id" value="<%= editId %>">
        <div class="form-grid">
            <div class="field">
                <label for="username">Nombre de usuario <span class="req">*</span></label>
                <input type="text" id="username" name="username" maxlength="50" required value="<%= Html(fName) %>">
            </div>
            <div class="field">
                <label for="email">Correo electrónico <span class="req">*</span></label>
                <input type="email" id="email" name="email" maxlength="50" required value="<%= Html(fEmail) %>">
            </div>
            <div class="field">
                <label for="birthday">Cumpleaños</label>
                <input type="date" id="birthday" name="birthday" value="<%= Html(fBirth) %>">
            </div>
            <div class="field">
                <label for="type">Tipo de usuario <span class="req">*</span></label>
                <select id="type" name="type" required>
                    <option value="0" <%= IIf(CInt(fType) = 0, "selected", "") %>>0 - Usuario Normal</option>
                    <option value="1" <%= IIf(CInt(fType) = 1, "selected", "") %>>1 - Administrador</option>
                </select>
            </div>
            <div class="field">
                <label for="password">Contraseña <% If Not isEdit Then %><span class="req">*</span><% End If %></label>
                <input type="text" id="password" name="password" maxlength="50" <% If Not isEdit Then %>required<% End If %>
                       placeholder="<%= IIf(isEdit, "Dejar vacío para no cambiarla", "Contraseña del usuario") %>">
                <div class="hint">Se almacena con hash SHA-1. El login también acepta contraseñas en texto plano sembradas en la BD.</div>
            </div>
            <div class="field">
                <label for="photo">Foto de perfil</label>
                <input type="text" id="photo" name="photo" maxlength="255" value="<%= Html(fPhoto) %>" placeholder="~/userImages/default.jpg">
                <div class="hint">Ruta como en la BD, ej. <code>~/userImages/root.png</code>. El archivo debe estar en <code>UserImages/</code>.</div>
            </div>
        </div>
        <div class="form-actions">
            <button type="submit" class="btn btn-primary"><%= Icon("plus", 16) %> <%= IIf(isEdit, "Guardar cambios", "Crear usuario") %></button>
            <a class="btn btn-ghost" href="users.asp">Cancelar</a>
        </div>
    </form>
</div>

<%= RenderShellClose() %>
