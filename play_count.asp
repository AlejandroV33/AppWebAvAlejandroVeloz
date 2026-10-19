<%
' =====================================================================
' PoliMusic - play_count.asp
' Incrementa el contador PLAYS de una canción (TBL_SONG).
' Se invoca desde el reproductor (app.js) cuando inicia una pista.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireLogin

Dim id
id = Request.Form("id")
If Not IsNumeric(id) Then
    Response.Status = "400 Bad Request"
    Response.Write "ERROR"
    Response.End
End If
id = CLng(id)

Dim db
Set db = OpenPoliDB()
db.Execute "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS, 0) + 1 WHERE ID_SONG = ?", Array(Array("id", id))
Set db = Nothing

Response.Write "OK"
%>
