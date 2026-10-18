<%
' =====================================================================
' PoliMusic - playlist_song_remove.asp  (SOLO ADMINISTRADORES)
' Quita una canción de una lista de reproducción.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim songId, playlistId
songId     = Request.Form("song_id")
playlistId = Request.Form("playlist_id")

If Not (IsNumeric(songId) And IsNumeric(playlistId)) Then
    SetFlash "error", "Solicitud inválida."
    RedirectTo "playlists.asp"
End If
songId     = CLng(songId)
playlistId = CLng(playlistId)

Dim db
Set db = DB()
db.Execute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", Array(Array("p", playlistId), Array("s", songId))
Set db = Nothing

SetFlash "success", "Canción quitada de la lista."
Response.Redirect "playlist_detail.asp?id=" & playlistId
%>
