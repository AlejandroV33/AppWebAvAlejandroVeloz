<%
' =====================================================================
' PoliMusic - includes/config.asp
' Configuración global: cadena de conexión, constantes ADODB,
' rutas de recursos, utilidades y SHA-1 puro (VBScript).
' Esquema objetivo: BDD_PoliMusic (TBL_USER, TBL_SONG, TBL_PLAYLIST,
' TBL_PLAYLIST_SONG, TBL_ARTIST, TBL_ALBUM, TBL_TRACKLIST, TBL_PLAYER,
' TBL_CATALOG).
' =====================================================================
Option Explicit

' ---------------------------------------------------------------------
' CADENA DE CONEXIÓN (SQL Server)
' El script BDD_PoliMusic.sql crea el login SQL "usr_polimusic"
' con password "Politecnica1" y lo agrega como db_owner de la base.
' Ajustar Data Source según la instancia instalada:
'   .\SQLEXPRESS            -> SQL Server Express
'   (localdb)\MSSQLLocalDB  -> LocalDB de Visual Studio
'   localhost               -> instancia por defecto
' ---------------------------------------------------------------------
Const DB_CONNSTR = "Provider=SQLOLEDB.1;Data Source=192.168.100.84,14333;Initial Catalog=BDD_PoliMusic;User ID=usr_polimusic;Password=Politecnica1;"

' Alternativa con autenticación de Windows (descomentar y comentar la de arriba):
'Const DB_CONNSTR = "Provider=SQLOLEDB.1;Data Source=192.168.100.84,14333;Initial Catalog=BDD_PoliMusic;Integrated Security=SSPI;"

' ---------------------------------------------------------------------
' Constantes ADODB (no vienen definidas por defecto en ASP clásico)
' ---------------------------------------------------------------------
Const adCmdText    = 1
Const adParamInput = 1
Const adVarChar    = 200
Const adVarWChar   = 202
Const adInteger    = 3
Const adBoolean    = 11
Const adDate       = 7
Const adUseClient  = 3

' ---------------------------------------------------------------------
' Carpetas de recursos en la raíz del proyecto
' (las rutasGuardadas en la BD usan el formato "~/carpeta/archivo")
' ---------------------------------------------------------------------
Const SONGS_FOLDER      = "SongFiles/"          ' pistas .mp3
Const USER_PHOTOS_FOLDER = "UserImages/"        ' fotos de perfil
Const PLAYLIST_PHOTOS_FOLDER = "PlaylistImages/" ' portadas de listas
Const DEFAULT_USER_PHOTO = "default.jpg"
Const DEFAULT_PLAYLIST_PHOTO = "default.jpg"

' ---------------------------------------------------------------------
' Codificación de salida
' ---------------------------------------------------------------------
Response.CodePage = 65001
Response.Charset = "UTF-8"
Response.LCID = 1033

' =====================================================================
' UTILIDADES GENERALES
' =====================================================================

Function Html(s)
    If IsNull(s) Or IsEmpty(s) Then s = ""
    Html = Server.HTMLEncode(CStr(s))
End Function

' Nombre de rol a partir de TBL_USER.USER_TYPE (ver TBL_CATALOG)
Function RoleName(userType)
    If CInt(userType & "0") = 1 Then RoleName = "Administrador" Else RoleName = "Usuario Normal"
End Function

' Tipo de lista a partir de TBL_PLAYLIST.TYPE (ver TBL_CATALOG)
Function PlaylistTypeName(t)
    If CInt(t & "0") = 1 Then PlaylistTypeName = "Privada" Else PlaylistTypeName = "Pública"
End Function

Sub SetFlash(kind, message)
    Session("flash_kind") = kind
    Session("flash_msg") = message
End Sub

Function RenderFlash()
    Dim k, m
    k = Session("flash_kind") & ""
    m = Session("flash_msg") & ""
    If Len(k) > 0 Then
        Session.Contents.Remove("flash_kind")
        Session.Contents.Remove("flash_msg")
        RenderFlash = "<div class=""flash flash-" & k & """ role=""alert"">" & _
                      "<span>" & Html(m) & "</span>" & _
                      "<button type=""button"" class=""flash-close"" aria-label=""Cerrar"">&times;</button></div>"
    Else
        RenderFlash = ""
    End If
End Function

' =====================================================================
' NORMALIZACIÓN DE RUTAS DE RECURSOS
' La BD guarda rutas tipo "~/songFiles/bensound-adventure.mp3".
' Estas funciones extraen solo el nombre del archivo (evitando rutas
' arbitrarias) y lo enrutan a la carpeta real del proyecto.
' =====================================================================
Function BaseName(p)
    Dim s
    s = CStr(p & "")
    s = Replace(s, "\", "/")
    If InStr(s, "/") > 0 Then s = Mid(s, InStrRev(s, "/") + 1)
    s = Replace(s, "..", "")
    BaseName = Trim(s)
End Function

' URL de una pista de audio (SongFiles/)
Function SongFileUrl(dbPath)
    Dim f
    f = BaseName(dbPath)
    If f = "" Then f = ""
    SongFileUrl = SONGS_FOLDER & f
End Function

' URL de la foto de un usuario (UserImages/)
Function UserPhotoUrl(dbPath)
    Dim f
    f = BaseName(dbPath)
    If f = "" Then f = DEFAULT_USER_PHOTO
    UserPhotoUrl = USER_PHOTOS_FOLDER & f
End Function

' URL de la portada de una lista (PlaylistImages/)
Function PlaylistPhotoUrl(dbPath)
    Dim f
    f = BaseName(dbPath)
    If f = "" Then f = DEFAULT_PLAYLIST_PHOTO
    PlaylistPhotoUrl = PLAYLIST_PHOTOS_FOLDER & f
End Function

' Atributo onerror para imágenes con fallback a la foto por defecto
Function ImgFallback(defaultUrl)
    ImgFallback = " onerror=""this.onerror=null;this.src='" & defaultUrl & "'"""
End Function

' =====================================================================
' SHA-1 PURO (VBScript) - usado para validar/almacenar contraseñas
' con hash (TBL_USER.PASSWORD acepta texto plano o hash SHA-1)
' =====================================================================
Function LooksLikeSha1(s)
    Dim i, ch
    s = LCase(Trim(CStr(s & "")))
    If Len(s) <> 40 Then LooksLikeSha1 = False : Exit Function
    For i = 1 To 40
        ch = Mid(s, i, 1)
        If InStr("0123456789abcdef", ch) = 0 Then LooksLikeSha1 = False : Exit Function
    Next
    LooksLikeSha1 = True
End Function

' Compara una contraseña ingresada con la almacenada (plano o SHA-1)
Function CheckPassword(inputPw, storedPw)
    inputPw = CStr(inputPw & "")
    storedPw = CStr(storedPw & "")
    If StrComp(inputPw, storedPw, vbTextCompare) = 0 Then
        CheckPassword = True
    ElseIf LooksLikeSha1(storedPw) And StrComp(Sha1Hex(inputPw), LCase(storedPw), vbTextCompare) = 0 Then
        CheckPassword = True
    Else
        CheckPassword = False
    End If
End Function

' Ajusta un valor a entero de 32 bits con signo (aritmética de SHA-1)
Function Wrap32(v)
    v = CDbl(v)
    v = v - Int(v / 4294967296.0) * 4294967296.0
    If v >= 2147483648.0 Then v = v - 4294967296.0
    Wrap32 = CLng(v)
End Function

' Rotación a la izquierda de 32 bits
Function Rotl32(x, n)
    Dim sh, mask
    sh = CLng(Int(CDbl(x) / (2 ^ (32 - n))))
    mask = CLng(2 ^ n - 1)
    Rotl32 = Wrap32(CDbl(x) * (2 ^ n) + CDbl(sh And mask))
End Function

Function Hex32(x)
    Dim s
    s = Hex(x)
    If Len(s) > 8 Then s = Right(s, 8)
    Hex32 = Right("00000000" & s, 8)
End Function

' Calcula el hash SHA-1 (hexadecimal minúscula) de un texto
Function Sha1Hex(message)
    Dim b(), i, n, ml, hi, lo, total, s, j, t
    Dim h0, h1, h2, h3, h4, a, bb, c, d, e, f, k, temp
    Dim w(79)

    h0 = 1732584193.0 : h1 = 4023233417.0 : h2 = 2562383102.0 : h3 = 271733878.0 : h4 = 3285377520.0

    n = Len(message)
    ReDim b(n + 71)
    For i = 1 To n
        b(i - 1) = CLng(Asc(Mid(message, i, 1))) And &HFF
    Next

    ml = n * 8
    b(n) = &H80
    i = n + 1
    Do While (i Mod 64) <> 56
        b(i) = 0
        i = i + 1
    Loop

    ' longitud del mensaje en bits (64 bits big-endian)
    hi = Int(ml / 4294967296.0)
    lo = ml - hi * 4294967296.0
    b(i)   = CLng(Int(hi / 16777216)) And &HFF
    b(i+1) = CLng(Int(hi / 65536)) And &HFF
    b(i+2) = CLng(Int(hi / 256)) And &HFF
    b(i+3) = CLng(hi) And &HFF
    b(i+4) = CLng(Int(lo / 16777216)) And &HFF
    b(i+5) = CLng(Int(lo / 65536)) And &HFF
    b(i+6) = CLng(Int(lo / 256)) And &HFF
    b(i+7) = CLng(lo) And &HFF
    i = i + 8
    total = i

    For s = 0 To total - 64 Step 64
        For j = 0 To 15
            w(j) = Wrap32(CDbl(b(s + j*4)) * 16777216 + CDbl(b(s + j*4 + 1)) * 65536 + _
                          CDbl(b(s + j*4 + 2)) * 256 + CDbl(b(s + j*4 + 3)))
        Next
        For t = 16 To 79
            w(t) = Rotl32(w(t-3) Xor w(t-8) Xor w(t-14) Xor w(t-16), 1)
        Next

        a = Wrap32(h0) : bb = Wrap32(h1) : c = Wrap32(h2) : d = Wrap32(h3) : e = Wrap32(h4)

        For t = 0 To 79
            If t < 20 Then
                f = (bb And c) Or ((Not bb) And d)
                k = 1518500249.0
            ElseIf t < 40 Then
                f = bb Xor c Xor d
                k = 1859775393.0
            ElseIf t < 60 Then
                f = (bb And c) Or (bb And d) Or (c And d)
                k = 2400959708.0
            Else
                f = bb Xor c Xor d
                k = 3395464782.0
            End If
            temp = Wrap32(CDbl(f) + CDbl(Rotl32(a, 5)) + CDbl(e) + k + CDbl(w(t)))
            e = d : d = c : c = Rotl32(bb, 30) : bb = a : a = temp
        Next

        h0 = Wrap32(CDbl(h0) + CDbl(a))
        h1 = Wrap32(CDbl(h1) + CDbl(bb))
        h2 = Wrap32(CDbl(h2) + CDbl(c))
        h3 = Wrap32(CDbl(h3) + CDbl(d))
        h4 = Wrap32(CDbl(h4) + CDbl(e))
    Next

    Sha1Hex = LCase(Hex32(h0) & Hex32(h1) & Hex32(h2) & Hex32(h3) & Hex32(h4))
End Function

' =====================================================================
' ICONOS SVG
' =====================================================================
Function Icon(name, size)
    If IsEmpty(size) Or size = "" Then size = 18
    Dim paths
    Select Case LCase(name)
        Case "home":     paths = "<path d='M3 10.5 12 3l9 7.5'/><path d='M5.5 9.5V20a1 1 0 0 0 1 1h11a1 1 0 0 0 1-1V9.5'/>"
        Case "playlist": paths = "<path d='M4 6h10M4 12h10M4 18h7'/><circle cx='18' cy='16' r='3'/><path d='M21 16V7l-3 1'/>"
        Case "album":    paths = "<circle cx='12' cy='12' r='9'/><circle cx='12' cy='12' r='2.6'/>"
        Case "artist":   paths = "<circle cx='12' cy='8' r='3.6'/><path d='M5 20c0-3.8 3.1-6.5 7-6.5s7 2.7 7 6.5'/>"
        Case "users":    paths = "<circle cx='9' cy='8' r='3.5'/><path d='M2.5 20c0-3.6 2.9-6 6.5-6s6.5 2.4 6.5 6'/><circle cx='17.5' cy='9' r='2.5'/><path d='M16 14.2c2.9.4 5 2.3 5 5.3'/>"
        Case "song":     paths = "<path d='M9 18V5l12-2v13'/><circle cx='6' cy='18' r='3'/><circle cx='18' cy='16' r='3'/>"
        Case "logout":   paths = "<path d='M15 17l5-5-5-5'/><path d='M20 12H9'/><path d='M12 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h6'/>"
        Case "play":     paths = "<path d='M7 4.5v15l13-7.5z' fill='currentColor' stroke='none'/>"
        Case "pause":    paths = "<rect x='6' y='4.5' width='4' height='15' rx='1' fill='currentColor' stroke='none'/><rect x='14' y='4.5' width='4' height='15' rx='1' fill='currentColor' stroke='none'/>"
        Case "next":     paths = "<path d='M5 4.5v15l10-7.5z' fill='currentColor' stroke='none'/><rect x='16.5' y='4.5' width='3' height='15' rx='1' fill='currentColor' stroke='none'/>"
        Case "prev":     paths = "<path d='M19 4.5v15L9 12z' fill='currentColor' stroke='none'/><rect x='4.5' y='4.5' width='3' height='15' rx='1' fill='currentColor' stroke='none'/>"
        Case "search":   paths = "<circle cx='11' cy='11' r='6.5'/><path d='M20 20l-4.2-4.2'/>"
        Case "plus":     paths = "<path d='M12 5v14M5 12h14'/>"
        Case "edit":     paths = "<path d='M12 20h9'/><path d='M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z'/>"
        Case "trash":    paths = "<path d='M3 6h18'/><path d='M8 6V4a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2'/><path d='M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6'/><path d='M10 11v6M14 11v6'/>"
        Case "music":    paths = "<path d='M9 18V5l12-2v13'/><circle cx='6' cy='18' r='3'/><circle cx='18' cy='16' r='3'/>"
        Case "volume":   paths = "<path d='M11 5 6.5 9H3v6h3.5L11 19z'/><path d='M15.5 8.5a5 5 0 0 1 0 7'/><path d='M18.5 5.5a9.5 9.5 0 0 1 0 13'/>"
        Case "menu":     paths = "<path d='M4 6h16M4 12h16M4 18h16'/>"
        Case "close":    paths = "<path d='M6 6l12 12M18 6L6 18'/>"
        Case "back":     paths = "<path d='M19 12H5'/><path d='M12 19l-7-7 7-7'/>"
        Case "eye":      paths = "<path d='M2 12s3.5-6.5 10-6.5S22 12 22 12s-3.5 6.5-10 6.5S2 12 2 12z'/><circle cx='12' cy='12' r='3'/>"
        Case "remove":   paths = "<path d='M5 12h14'/>"
        Case "plays":    paths = "<path d='M3 12h3l3-7 4 14 3-7h5'/>"
        Case Else:       paths = "<circle cx='12' cy='12' r='9'/>"
    End Select
    Icon = "<svg class=""icon"" width=""" & size & """ height=""" & size & """ viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""1.8"" stroke-linecap=""round"" stroke-linejoin=""round"" aria-hidden=""true"">" & paths & "</svg>"
End Function
%>
