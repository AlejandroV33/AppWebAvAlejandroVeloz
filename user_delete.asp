<%
' =====================================================================
' PoliMusic - user_delete.asp  (SOLO ADMINISTRADORES)
' Elimina un usuario de TBL_USER.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim id
id = Request.Form("id")
If Not IsNumeric(id) Then
    SetFlash "error", "Solicitud inválida."
    RedirectTo "users.asp"
End If
id = CLng(id)

If id = CurrentUserId() Then
    SetFlash "error", "No puedes eliminar tu propio usuario mientras estás conectado."
    RedirectTo "users.asp"
End If

Dim db
Set db = DB()
db.Execute "DELETE FROM TBL_USER WHERE ID_USER = ?", Array(Array("id", id))
Set db = Nothing

SetFlash "success", "Usuario eliminado correctamente."
Response.Redirect "users.asp"
%>
