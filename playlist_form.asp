<%
' =====================================================================
' PoliMusic - playlist_form.asp  (SOLO ADMINISTRADORES)
' Crear / editar una lista de reproducción (TBL_PLAYLIST).
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

Dim fTitle, fType, fPhoto, fOwner
fTitle = "" : fType = 0 : fPhoto = "" : fOwner = CurrentUserId()

Dim db, rs
Set db = DB()

If isEdit Then
    Set rs = db.Recordset("SELECT ID_USER, TITLE, TYPE, PHOTO FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(Array("id", editId)))
    If rs.EOF Then
        SetFlash "error", "La lista no existe."
        RedirectTo "playlists.asp"
    End If
    fOwner = rs.Fields("ID_USER").Value
    fTitle = rs.Fields("TITLE").Value
    fType  = rs.Fields("TYPE").Value
    fPhoto = rs.Fields("PHOTO").Value
    rs.Close
    Set rs = Nothing
End If

Set rs = db.Recordset("SELECT ID_USER, USERNAME FROM TBL_USER ORDER BY USERNAME")
%>
<%= RenderHead(IIf(isEdit, "Editar lista", "Nueva lista")) %>
<%= RenderShellOpen("playlists", IIf(isEdit, "Editar lista", "Nueva lista"), "Gestión de listas de reproducción", "") %>

<%= RenderFlash() %>

<div class="form-card">
    <form method="post" action="playlist_save.asp">
        <input type="hidden" name="id" value="<%= editId %>">
        <div class="form-grid">
            <div class="field full">
                <label for="title">Título de la lista <span class="req">*</span></label>
                <input type="text" id="title" name="title" maxlength="50" required value="<%= Html(fTitle) %>">
            </div>
            <div class="field">
                <label for="type">Tipo <span class="req">*</span></label>
                <select id="type" name="type" required>
                    <option value="0" <%= IIf(CInt(fType) = 0, "selected", "") %>>0 - Pública</option>
                    <option value="1" <%= IIf(CInt(fType) = 1, "selected", "") %>>1 - Privada</option>
                </select>
            </div>
            <div class="field">
                <label for="photo">Portada</label>
                <input type="text" id="photo" name="photo" maxlength="255" value="<%= Html(fPhoto) %>" placeholder="~/playlistImages/default.jpg">
                <div class="hint">Ruta como en la BD, ej. <code>~/playlistImages/playlist1.png</code>. El archivo debe estar en <code>PlaylistImages/</code>.</div>
            </div>
            <div class="field full">
                <label for="user_id">Creador <span class="req">*</span></label>
                <select id="user_id" name="user_id" required>
                    <% Do While Not rs.EOF %>
                    <option value="<%= rs.Fields("ID_USER").Value %>" <%= IIf(CLng(fOwner) = CLng(rs.Fields("ID_USER").Value), "selected", "") %>>
                        <%= Html(rs.Fields("USERNAME").Value) %>
                    </option>
                    <% rs.MoveNext : Loop %>
                </select>
            </div>
        </div>
        <div class="form-actions">
            <button type="submit" class="btn btn-primary"><%= Icon("plus", 16) %> <%= IIf(isEdit, "Guardar cambios", "Crear lista") %></button>
            <a class="btn btn-ghost" href="playlists.asp">Cancelar</a>
        </div>
    </form>
</div>

<%= RenderShellClose() %>
<%
rs.Close
Set rs = Nothing
Set db = Nothing
%>
