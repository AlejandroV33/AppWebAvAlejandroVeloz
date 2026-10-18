<%
' =====================================================================
' PoliMusic - playlist_save.asp  (SOLO ADMINISTRADORES)
' Inserta o actualiza una lista de reproducción.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim id, title_, type_, photo, owner
id     = Request.Form("id")
title_ = Trim(Request.Form("title") & "")
type_  = Request.Form("type")
photo  = Trim(Request.Form("photo") & "")
owner  = Request.Form("user_id")

If IsNumeric(id) Then id = CLng(id) Else id = 0
If IsNumeric(type_) Then type_ = CInt(type_) Else type_ = 0
If IsNumeric(owner) Then owner = CLng(owner) Else owner = CurrentUserId()

If title_ = "" Then
    SetFlash "error", "El título de la lista es obligatorio."
    RedirectTo "playlist_form.asp?id=" & id
End If

Dim db
Set db = DB()

If id > 0 Then
    db.Execute "UPDATE TBL_PLAYLIST SET TITLE = ?, TYPE = ?, PHOTO = ?, ID_USER = ? WHERE ID_PLAYLIST = ?", _
        Array(Array("title", title_), Array("type", type_), Array("photo", IIf(photo = "", Null, photo)), _
              Array("owner", owner), Array("id", id))
    SetFlash "success", "Lista actualizada correctamente."
Else
    db.Execute "INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO) VALUES (?, ?, GETDATE(), ?, ?)", _
        Array(Array("owner", owner), Array("title", title_), Array("type", type_), Array("photo", IIf(photo = "", Null, photo)))
    SetFlash "success", "Lista creada correctamente."
End If

Set db = Nothing
Response.Redirect "playlists.asp"
%>
