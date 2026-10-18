<%
' =====================================================================
' PoliMusic - logout.asp
' Destruye la sesión actual y redirige a la pantalla de login.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<%
Session.Abandon()
Response.Redirect "login.asp"
%>
