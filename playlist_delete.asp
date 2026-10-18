<%
' =====================================================================
' PoliMusic - playlist_delete.asp  (SOLO ADMINISTRADORES)
' Elimina una lista y sus canciones asociadas.
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
    RedirectTo "playlists.asp"
End If
id = CLng(id)

Dim db
Set db = DB()
db.Execute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?", Array(Array("id", id))
db.Execute "DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(Array("id", id))
Set db = Nothing

SetFlash "success", "Lista eliminada correctamente."
Response.Redirect "playlists.asp"
%>
