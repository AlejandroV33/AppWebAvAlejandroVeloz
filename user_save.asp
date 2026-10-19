<%
' =====================================================================
' PoliMusic - user_save.asp  (SOLO ADMINISTRADORES)
' Inserta o actualiza un usuario en TBL_USER.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim id, username_, email_, birthday_, type_, password, photo
id        = Request.Form("id")
username_ = Trim(Request.Form("username") & "")
email_    = Trim(Request.Form("email") & "")
birthday_ = Trim(Request.Form("birthday") & "")
type_     = Request.Form("type")
password  = Request.Form("password") & ""
photo     = Trim(Request.Form("photo") & "")

If IsNumeric(id) Then id = CLng(id) Else id = 0
If IsNumeric(type_) Then type_ = CInt(type_) Else type_ = 0

If username_ = "" Or email_ = "" Then
    SetFlash "error", "El nombre de usuario y el correo son obligatorios."
    RedirectTo "user_form.asp?id=" & id
End If

Dim db, dup
Set db = OpenPoliDB()

' Usuario y correo únicos (excluyendo el propio registro al editar)
dup = db.Scalar("SELECT COUNT(*) FROM TBL_USER WHERE (USERNAME = ? OR EMAIL = ?) AND ID_USER <> ?", _
    Array(Array("u", username_), Array("e", email_), Array("id", id)))
If CLng(dup & "0") > 0 Then
    Set db = Nothing
    SetFlash "error", "El nombre de usuario o el correo ya están registrados."
    RedirectTo "user_form.asp?id=" & id
End If

Dim bday
bday = Null
If IsDate(birthday_) Then bday = CDate(birthday_)

If id > 0 Then
    ' --- UPDATE ---
    If password <> "" Then
        db.Execute "UPDATE TBL_USER SET USERNAME = ?, EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ?, USER_TYPE = ?, PASSWORD = ? WHERE ID_USER = ?", _
            Array(Array("u", username_), Array("e", email_), Array("b", bday), _
                  Array("p", IIf(photo = "", Null, photo)), Array("t", type_), Array("pw", Sha1Hex(password)), Array("id", id))
    Else
        db.Execute "UPDATE TBL_USER SET USERNAME = ?, EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ?, USER_TYPE = ? WHERE ID_USER = ?", _
            Array(Array("u", username_), Array("e", email_), Array("b", bday), _
                  Array("p", IIf(photo = "", Null, photo)), Array("t", type_), Array("id", id))
    End If

    ' Si el admin editó su propio perfil, refrescar la sesión
    If id = CurrentUserId() Then
        Session("USERNAME")   = username_
        Session("EMAIL")      = email_
        Session("USER_TYPE")  = type_
        Session("USER_PHOTO") = photo
    End If

    SetFlash "success", "Usuario actualizado correctamente."
Else
    ' --- INSERT ---
    If password = "" Then
        Set db = Nothing
        SetFlash "error", "La contraseña es obligatoria para un usuario nuevo."
        RedirectTo "user_form.asp"
    End If

    db.Execute "INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE) VALUES (?, ?, ?, ?, ?, ?)", _
        Array(Array("u", username_), Array("pw", Sha1Hex(password)), Array("e", email_), _
              Array("b", bday), Array("p", IIf(photo = "", Null, photo)), Array("t", type_))

    SetFlash "success", "Usuario creado correctamente."
End If

Set db = Nothing
Response.Redirect "users.asp"
%>
