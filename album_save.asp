<%
' =====================================================================
' PoliMusic - album_save.asp  (SOLO ADMINISTRADORES)
' Inserta o actualiza un álbum en TBL_ALBUM.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim id, title_, year_, image_
id     = Request.Form("id")
title_ = Trim(Request.Form("title") & "")
year_  = Trim(Request.Form("year") & "")
image_ = Trim(Request.Form("image") & "")

If IsNumeric(id) Then id = CLng(id) Else id = 0

If title_ = "" Then
    SetFlash "error", "El título del álbum es obligatorio."
    RedirectTo "album_form.asp?id=" & id
End If

Dim yr
yr = Null
If IsNumeric(year_) Then yr = CLng(year_)

Dim db
Set db = DB()

If id > 0 Then
    db.Execute "UPDATE TBL_ALBUM SET TITLE_ALBUM = ?, RELEASE_YEAR = ?, ALBUM_IMAGE_PATH = ? WHERE ID_ALBUM = ?", _
        Array(Array("t", title_), Array("y", yr), Array("i", IIf(image_ = "", Null, image_)), Array("id", id))
    SetFlash "success", "Álbum actualizado correctamente."
Else
    db.Execute "INSERT INTO TBL_ALBUM (TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH) VALUES (?, ?, ?)", _
        Array(Array("t", title_), Array("y", yr), Array("i", IIf(image_ = "", Null, image_)))
    SetFlash "success", "Álbum creado correctamente."
End If

Set db = Nothing
Response.Redirect "albums.asp"
%>
