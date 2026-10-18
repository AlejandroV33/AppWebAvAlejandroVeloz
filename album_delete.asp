<%
' =====================================================================
' PoliMusic - album_delete.asp  (SOLO ADMINISTRADORES)
' Elimina un álbum y sus relaciones (TBL_TRACKLIST).
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
    RedirectTo "albums.asp"
End If
id = CLng(id)

Dim db
Set db = DB()
db.Execute "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(Array("id", id))
db.Execute "DELETE FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(Array("id", id))
Set db = Nothing

SetFlash "success", "Álbum eliminado correctamente."
Response.Redirect "albums.asp"
%>
