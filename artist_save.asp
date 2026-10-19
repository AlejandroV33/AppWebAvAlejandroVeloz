<%
' =====================================================================
' PoliMusic - artist_save.asp  (SOLO ADMINISTRADORES)
' Inserta o actualiza un artista en TBL_ARTIST.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim id, name_, last_, image_
id     = Request.Form("id")
name_  = Trim(Request.Form("name") & "")
last_  = Trim(Request.Form("lastname") & "")
image_ = Trim(Request.Form("image") & "")

If IsNumeric(id) Then id = CLng(id) Else id = 0

If name_ = "" Then
    SetFlash "error", "El nombre del artista es obligatorio."
    RedirectTo "artist_form.asp?id=" & id
End If

Dim db
Set db = OpenPoliDB()

If id > 0 Then
    db.Execute "UPDATE TBL_ARTIST SET ARTIST_NAME = ?, ARTIST_LASTNAME = ?, ARTIST_IMAGE = ? WHERE ID_ARTIST = ?", _
        Array(Array("n", name_), Array("l", IIf(last_ = "", Null, last_)), Array("i", IIf(image_ = "", Null, image_)), Array("id", id))
    SetFlash "success", "Artista actualizado correctamente."
Else
    db.Execute "INSERT INTO TBL_ARTIST (ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE) VALUES (?, ?, ?)", _
        Array(Array("n", name_), Array("l", IIf(last_ = "", Null, last_)), Array("i", IIf(image_ = "", Null, image_)))
    SetFlash "success", "Artista creado correctamente."
End If

Set db = Nothing
Response.Redirect "artists.asp"
%>
