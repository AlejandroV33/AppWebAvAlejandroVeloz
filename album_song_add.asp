<%
' =====================================================================
' PoliMusic - album_song_add.asp  (SOLO ADMINISTRADORES)
' Agrega una canción a un álbum (TBL_TRACKLIST).
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim albumId, songId
albumId = Request.Form("album_id")
songId  = Request.Form("song_id")

If Not (IsNumeric(albumId) And IsNumeric(songId)) Then
    SetFlash "error", "Solicitud inválida."
    RedirectTo "albums.asp"
End If
albumId = CLng(albumId)
songId  = CLng(songId)

Dim db, dup
Set db = OpenPoliDB()

dup = db.Scalar("SELECT COUNT(*) FROM TBL_TRACKLIST WHERE ID_ALBUM = ? AND ID_SONG = ?", Array(Array("a", albumId), Array("s", songId)))
If CLng(dup & "0") = 0 Then
    db.Execute "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)", Array(Array("a", albumId), Array("s", songId))
    SetFlash "success", "Canción agregada al álbum."
Else
    SetFlash "info", "La canción ya estaba en el álbum."
End If

Set db = Nothing
Response.Redirect "album_detail.asp?id=" & albumId
%>
