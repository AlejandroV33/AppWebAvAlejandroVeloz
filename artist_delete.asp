<%
' =====================================================================
' PoliMusic - artist_delete.asp  (SOLO ADMINISTRADORES)
' Elimina un artista y sus relaciones con canciones.
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
    RedirectTo "artists.asp"
End If
id = CLng(id)

Dim db
Set db = DB()
db.Execute "DELETE FROM TBL_PLAYER WHERE ID_ARTIST = ?", Array(Array("id", id))
db.Execute "DELETE FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(Array("id", id))
Set db = Nothing

SetFlash "success", "Artista eliminado correctamente."
Response.Redirect "artists.asp"
%>
