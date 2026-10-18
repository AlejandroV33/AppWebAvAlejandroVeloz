<%
' =====================================================================
' PoliMusic - playlist_song_add.asp  (SOLO ADMINISTRADORES)
' Agrega una canción existente a una lista (TBL_PLAYLIST_SONG).
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim playlistId, songId
playlistId = Request.Form("playlist_id")
songId     = Request.Form("song_id")

If Not (IsNumeric(playlistId) And IsNumeric(songId)) Then
    SetFlash "error", "Solicitud inválida."
    RedirectTo "playlists.asp"
End If
playlistId = CLng(playlistId)
songId     = CLng(songId)

Dim db, dup
Set db = DB()

dup = db.Scalar("SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", Array(Array("p", playlistId), Array("s", songId)))
If CLng(dup & "0") = 0 Then
    db.Execute "INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (?, ?)", Array(Array("p", playlistId), Array("s", songId))
    SetFlash "success", "Canción agregada a la lista."
Else
    SetFlash "info", "La canción ya estaba en la lista."
End If

Set db = Nothing
Response.Redirect "playlist_detail.asp?id=" & playlistId
%>
