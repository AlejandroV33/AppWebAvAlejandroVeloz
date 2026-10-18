<%
' =====================================================================
' PoliMusic - song_save.asp  (SOLO ADMINISTRADORES)
' Inserta o actualiza una canción en TBL_SONG y sincroniza TBL_PLAYER.
' Verifica que el archivo .mp3 exista en SongFiles/.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim id, songName, songPath
id       = Request.Form("id")
songName = Trim(Request.Form("name") & "")
songPath = Trim(Request.Form("path") & "")

If IsNumeric(id) Then id = CLng(id) Else id = 0

If songName = "" Or songPath = "" Then
    SetFlash "error", "El nombre y la ruta del archivo son obligatorios."
    RedirectTo "song_form.asp?id=" & id
End If

' El archivo debe existir físicamente en SongFiles/
Dim fso, fullPath
Set fso = Server.CreateObject("Scripting.FileSystemObject")
fullPath = Server.MapPath(SONGS_FOLDER & BaseName(songPath))
If Not fso.FileExists(fullPath) Then
    Set fso = Nothing
    SetFlash "error", "El archivo """ & BaseName(songPath) & """ no existe en la carpeta SongFiles/. Colócalo ahí antes de guardar."
    RedirectTo "song_form.asp?id=" & id
End If
Set fso = Nothing

Dim db
Set db = DB()

Dim newId
newId = id

If id > 0 Then
    db.Execute "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ? WHERE ID_SONG = ?", _
        Array(Array("name", songName), Array("path", songPath), Array("id", id))
    SetFlash "success", "Canción actualizada correctamente."
Else
    db.Execute "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, 0)", _
        Array(Array("name", songName), Array("path", songPath))
    newId = CLng(db.Scalar("SELECT @@IDENTITY", Nothing))
    SetFlash "success", "Canción creada correctamente."
End If

' --- Sincronizar artistas (TBL_PLAYER) ---
db.Execute "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(Array("id", newId))
Dim artistIds, k
artistIds = Split(Request.Form("artists") & "", ",")
For k = LBound(artistIds) To UBound(artistIds)
    If IsNumeric(Trim(artistIds(k))) And Trim(artistIds(k)) <> "" Then
        db.Execute "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (?, ?)", _
            Array(Array("s", newId), Array("a", CLng(Trim(artistIds(k)))))
    End If
Next

Set db = Nothing
Response.Redirect "index.asp"
%>
