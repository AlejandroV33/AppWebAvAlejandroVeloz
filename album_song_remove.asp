<%
' =====================================================================
' PoliMusic - album_song_remove.asp  (SOLO ADMINISTRADORES)
' Quita una canción de un álbum.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim songId, albumId
songId = Request.Form("song_id")
albumId = Request.Form("album_id")

If Not (IsNumeric(songId) And IsNumeric(albumId)) Then
    SetFlash "error", "Solicitud inválida."
    RedirectTo "albums.asp"
End If
songId  = CLng(songId)
albumId = CLng(albumId)

Dim db
Set db = DB()
db.Execute "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ? AND ID_SONG = ?", Array(Array("a", albumId), Array("s", songId))
Set db = Nothing

SetFlash "success", "Canción quitada del álbum."
Response.Redirect "album_detail.asp?id=" & albumId
%>
