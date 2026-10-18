<%
' =====================================================================
' PoliMusic - users.asp  (SOLO ADMINISTRADORES)
' Listado de usuarios (TBL_USER) con acciones CRUD.
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/layout.asp"-->
<%
RequireAdmin

Dim db, rs, actions
Set db = DB()
Set rs = db.Recordset("SELECT ID_USER, USERNAME, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE FROM TBL_USER ORDER BY ID_USER")

actions = "<a class=""btn btn-primary"" href=""user_form.asp"">" & Icon("plus", 16) & "<span>Nuevo usuario</span></a>"
%>
<%= RenderHead("Usuarios") %>
<%= RenderShellOpen("users", "Gestión de usuarios", "Solo administradores", actions) %>

<%= RenderFlash() %>

<div class="table-wrap">
    <div class="table-scroll">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Usuario</th>
                    <th>Correo</th>
                    <th>Cumpleaños</th>
                    <th>Tipo</th>
                    <th style="text-align:right">Acciones</th>
                </tr>
            </thead>
            <tbody>
            <%
            Do While Not rs.EOF
                Dim uId, uName, uEmail, uBirth, uPhoto, uType
                uId    = rs.Fields("ID_USER").Value
                uName  = rs.Fields("USERNAME").Value
                uEmail = rs.Fields("EMAIL").Value
                uBirth = rs.Fields("BIRTHDAY").Value
                uPhoto = rs.Fields("USER_PHOTO").Value
                uType  = rs.Fields("USER_TYPE").Value
            %>
                <tr>
                    <td>
                        <div class="song-cell">
                            <img class="avatar" src="<%= UserPhotoUrl(uPhoto) %>" alt="Avatar de <%= Html(uName) %>"<%= ImgFallback(USER_PHOTOS_FOLDER & DEFAULT_USER_PHOTO) %>>
                            <div>
                                <div class="song-title"><%= Html(uName) %></div>
                                <div class="song-sub">ID: <%= uId %><% If uId = CurrentUserId() Then %> &middot; (tú)<% End If %></div>
                            </div>
                        </div>
                    </td>
                    <td class="cell-dim"><%= Html(uEmail) %></td>
                    <td class="cell-dim"><%= IIf(IsNull(uBirth), "—", CStr(FormatDateTime(uBirth, vbShortDate))) %></td>
                    <td><span class="<%= IIf(CInt(uType) = 1, "chip chip-admin", "chip chip-user") %>"><%= Html(RoleName(uType)) %></span></td>
                    <td>
                        <div class="row-actions">
                            <a class="icon-btn" href="user_form.asp?id=<%= uId %>" title="Editar usuario"><%= Icon("edit", 17) %></a>
                            <% If uId <> CurrentUserId() Then %>
                            <form class="inline-form" method="post" action="user_delete.asp" data-confirm="¿Eliminar al usuario '<%= Replace(Html(uName), "'", "") %>'? Esta acción no se puede deshacer.">
                                <input type="hidden" name="id" value="<%= uId %>">
                                <button class="icon-btn icon-btn--danger" type="submit" title="Eliminar usuario"><%= Icon("trash", 17) %></button>
                            </form>
                            <% End If %>
                        </div>
                    </td>
                </tr>
            <%
                rs.MoveNext
            Loop
            %>
            </tbody>
        </table>
    </div>
</div>

<%= RenderShellClose() %>
<%
rs.Close
Set rs = Nothing
Set db = Nothing
%>
