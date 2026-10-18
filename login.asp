<%
' =====================================================================
' PoliMusic - login.asp
' Pantalla de inicio de sesión. Valida credenciales contra TBL_USER
' (login por USERNAME o EMAIL; la contraseña puede estar en texto
' plano o como hash SHA-1).
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/layout.asp"-->
<%
Dim errorMsg
errorMsg = ""

If Len(Session("ID_USER") & "") > 0 Then Response.Redirect "index.asp"

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim login, password
    login    = Trim(Request.Form("username") & "")
    password = Request.Form("password") & ""

    If login = "" Or password = "" Then
        errorMsg = "Debes ingresar tu usuario/correo y tu contraseña."
    Else
        Dim db, rs
        Set db = DB()
        Set rs = db.Recordset( _
            "SELECT ID_USER, USERNAME, PASSWORD, EMAIL, USER_TYPE, USER_PHOTO " & _
            "FROM TBL_USER WHERE USERNAME = ? OR EMAIL = ?", _
            Array(Array("u1", login), Array("u2", login)))

        Dim loggedIn : loggedIn = False
        Do While Not rs.EOF
            If CheckPassword(password, rs.Fields("PASSWORD").Value) Then
                Session("ID_USER")    = rs.Fields("ID_USER").Value
                Session("USERNAME")   = rs.Fields("USERNAME").Value
                Session("EMAIL")      = rs.Fields("EMAIL").Value
                Session("USER_TYPE")  = rs.Fields("USER_TYPE").Value
                Session("USER_PHOTO") = rs.Fields("USER_PHOTO").Value
                Session.Timeout = 60
                loggedIn = True
                Exit Do
            End If
            rs.MoveNext
        Loop
        rs.Close
        Set rs = Nothing
        Set db = Nothing

        If loggedIn Then
            Dim back
            back = Session("redirect_after_login") & ""
            If Len(back) > 0 Then
                Session.Contents.Remove("redirect_after_login")
                Response.Redirect back
            Else
                Response.Redirect "index.asp"
            End If
        Else
            errorMsg = "Usuario o contraseña incorrectos."
        End If
    End If
End If
%>
<%= RenderHead("Iniciar sesión") %>
<div class="login-body">
    <div class="login-card">
        <div class="login-logo">
            <span class="brand-mark"><%= Icon("song", 24) %></span>
            <span class="brand-name">Poli<em>Music</em></span>
        </div>
        <p class="login-sub">Inicia sesión para disfrutar de tu música</p>

        <% If errorMsg <> "" Then %>
        <div class="form-error"><%= Html(errorMsg) %></div>
        <% End If %>

        <form method="post" action="login.asp" autocomplete="off">
            <div class="field">
                <label for="username">Usuario o correo <span class="req">*</span></label>
                <input type="text" id="username" name="username" placeholder="userNormal" required
                       value="<%= Html(Request.Form("username") & "") %>">
            </div>
            <div class="field">
                <label for="password">Contraseña <span class="req">*</span></label>
                <input type="password" id="password" name="password" placeholder="••••••••" required>
            </div>
            <button type="submit" class="btn btn-primary">Entrar</button>
        </form>

        <div class="login-hint">
            <b>Usuarios de prueba (BDD_PoliMusic):</b><br>
            <code>userNormal</code> / <code>12345678</code> — Usuario Normal<br>
            <code>userAdmin</code> / <code>12345678</code> — Administrador<br>
            <code>username1</code> / <code>12345678</code> — contraseña con hash SHA-1
        </div>
    </div>
</div>
</body>
</html>
