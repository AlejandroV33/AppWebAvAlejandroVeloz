<%
' =====================================================================
' PoliMusic - song_delete.asp  (SOLO ADMINISTRADORES)
' Elimina una canción de TBL_SONG y sus relaciones.
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
    RedirectTo "index.asp"
End If
id = CLng(id)

Dim db
Set db = OpenPoliDB()
db.Execute "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(Array("id", id))
db.Execute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?", Array(Array("id", id))
db.Execute "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(Array("id", id))
db.Execute "DELETE FROM TBL_SONG WHERE ID_SONG = ?", Array(Array("id", id))
Set db = Nothing

SetFlash "success", "Canción eliminada correctamente."
Response.Redirect "index.asp"
%>
