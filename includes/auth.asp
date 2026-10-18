<%
' =====================================================================
' PoliMusic - includes/auth.asp
' Control de sesión, roles y permisos.
'
' Variables de sesión definidas al iniciar sesión:
'   Session("ID_USER")   : TBL_USER.ID_USER
'   Session("USERNAME")  : TBL_USER.USERNAME
'   Session("EMAIL")     : TBL_USER.EMAIL
'   Session("USER_TYPE") : TBL_USER.USER_TYPE (0 = Normal, 1 = Admin)
'   Session("USER_PHOTO"): TBL_USER.USER_PHOTO
' =====================================================================

Sub RequireLogin()
    If Len(Session("ID_USER") & "") = 0 Then
        Session("redirect_after_login") = Request.ServerVariables("SCRIPT_NAME") & "?" & Request.ServerVariables("QUERY_STRING")
        Response.Redirect "login.asp"
    End If
End Sub

Sub RequireAdmin()
    RequireLogin
    If CInt(Session("USER_TYPE") & "") <> 1 Then
        Response.Clear
        Response.Status = "403 Forbidden"
        Response.Write "<!DOCTYPE html>" & vbCrLf
        Response.Write "<html lang=""es"">" & vbCrLf
        Response.Write "<head>" & vbCrLf
        Response.Write "<meta charset=""UTF-8"">" & vbCrLf
        Response.Write "<meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">" & vbCrLf
        Response.Write "<title>403 - Acceso denegado | PoliMusic</title>" & vbCrLf
        Response.Write "<link rel=""stylesheet"" href=""assets/css/style.css"">" & vbCrLf
        Response.Write "</head>" & vbCrLf
        Response.Write "<body class=""error-page"">" & vbCrLf
        Response.Write "<div class=""error-box"">" & vbCrLf
        Response.Write "  <div class=""error-code"">403</div>" & vbCrLf
        Response.Write "  <h1>Acceso denegado</h1>" & vbCrLf
        Response.Write "  <p>No tienes permisos de administrador para acceder a esta sección.</p>" & vbCrLf
        Response.Write "  <a class=""btn btn-primary"" href=""index.asp"">Volver al inicio</a>" & vbCrLf
        Response.Write "</div>" & vbCrLf
        Response.Write "</body>" & vbCrLf
        Response.Write "</html>"
        Response.End
    End If
End Sub

Function IsAdmin()
    IsAdmin = (Len(Session("ID_USER") & "") > 0 And CInt(Session("USER_TYPE") & "") = 1)
End Function

Function CurrentUsername()
    CurrentUsername = Session("USERNAME") & ""
End Function

Function CurrentUserId()
    CurrentUserId = CLng(Session("ID_USER") & "0")
End Function

Function CurrentUserPhoto()
    CurrentUserPhoto = Session("USER_PHOTO") & ""
End Function
%>
