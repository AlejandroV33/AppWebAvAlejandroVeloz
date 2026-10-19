<%
' =====================================================================
' PoliMusic - song_form.asp  (SOLO ADMINISTRADORES)
' Crear / editar una canción (TBL_SONG) y sus artistas (TBL_PLAYER).
' =====================================================================
%>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/layout.asp"-->
<%
RequireAdmin

Dim editId, isEdit, pageTitle, submitLabel, artistChecked
editId = Request.QueryString("id")
isEdit = False
If IsNumeric(editId) And CLng(editId) > 0 Then
    editId = CLng(editId)
    isEdit = True
Else
    editId = 0
End If
If isEdit Then
    pageTitle = "Editar canción"
    submitLabel = "Guardar cambios"
Else
    pageTitle = "Nueva canción"
    submitLabel = "Crear canción"
End If

Dim fName, fPath
fName = "" : fPath = ""

Dim db, rs
Set db = OpenPoliDB()

' Artistas actuales de la canción (para preseleccionar)
Dim currentArtists
currentArtists = ""
If isEdit Then
    Set rs = db.Recordset("SELECT SONG_NAME, SONG_PATH FROM TBL_SONG WHERE ID_SONG = ?", Array(Array("id", editId)))
    If rs.EOF Then
        SetFlash "error", "La canción no existe."
        RedirectTo "index.asp"
    End If
    fName = rs.Fields("SONG_NAME").Value
    fPath = rs.Fields("SONG_PATH").Value
    rs.Close
    Set rs = Nothing

    Set rs = db.Recordset("SELECT ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = ?", Array(Array("id", editId)))
    Do While Not rs.EOF
        currentArtists = currentArtists & "," & CStr(rs.Fields("ID_ARTIST").Value)
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing
    currentArtists = currentArtists & ","
End If

Set rs = db.Recordset("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME FROM TBL_ARTIST ORDER BY ARTIST_NAME", Nothing)
%>
<%= RenderHead(pageTitle) %>
<%= RenderShellOpen("home", pageTitle, "Gestión de canciones", "") %>

<%= RenderFlash() %>

<div class="form-card">
    <form method="post" action="song_save.asp">
        <input type="hidden" name="id" value="<%= editId %>">
        <div class="form-grid">
            <div class="field">
                <label for="name">Nombre de la canción <span class="req">*</span></label>
                <input type="text" id="name" name="name" maxlength="50" required value="<%= Html(fName) %>">
            </div>
            <div class="field">
                <label for="path">Archivo de audio <span class="req">*</span></label>
                <input type="text" id="path" name="path" maxlength="255" required value="<%= Html(fPath) %>" placeholder="~/songFiles/bensound-adventure.mp3">
                <div class="hint">Ruta como en la BD, ej. <code>~/songFiles/archivo.mp3</code>. El archivo debe existir en <code>SongFiles/</code>.</div>
            </div>
            <div class="field full">
                <label>Artistas (TBL_PLAYER)</label>
                <div style="display:flex;flex-wrap:wrap;gap:8px;background:var(--bg-0);border:1px solid var(--border);border-radius:9px;padding:12px">
                <% Do While Not rs.EOF %>
                    <% If InStr(currentArtists, "," & CStr(rs.Fields("ID_ARTIST").Value) & ",") > 0 Then artistChecked = "checked" Else artistChecked = "" %>
                    <label style="display:inline-flex;align-items:center;gap:7px;font-size:13.5px;color:var(--text-dim);cursor:pointer">
                        <input type="checkbox" name="artists" value="<%= rs.Fields("ID_ARTIST").Value %>"
                            <%= artistChecked %>>
                        <%= Html(rs.Fields("ARTIST_NAME").Value & "") %><% If Not IsNull(rs.Fields("ARTIST_LASTNAME").Value) And rs.Fields("ARTIST_LASTNAME").Value <> "" Then %> <%= Html(rs.Fields("ARTIST_LASTNAME").Value) %><% End If %>
                    </label>
                <% rs.MoveNext : Loop %>
                </div>
            </div>
        </div>
        <div class="form-actions">
            <button type="submit" class="btn btn-primary"><%= Icon("plus", 16) %> <%= submitLabel %></button>
            <a class="btn btn-ghost" href="index.asp">Cancelar</a>
        </div>
    </form>
</div>

<%= RenderShellClose() %>
<%
rs.Close
Set rs = Nothing
Set db = Nothing
%>
