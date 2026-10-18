<%
' =====================================================================
' PoliMusic - includes/db.asp
' Capa de acceso a datos (Class PoliDB).
' Todas las consultas usan comandos parametrizados de ADODB para
' prevenir inyección de SQL.
'
' Uso:
'   Dim db : Set db = DB()
'   Dim id : id = db.Scalar("SELECT ID_USER FROM TBL_USER WHERE USERNAME = ?", Array(Array("u", Request.Form("username"))))
'   Dim rs : Set rs = db.Recordset("SELECT * FROM TBL_SONG ORDER BY ID_SONG")
'   Dim n  : n = db.Execute("DELETE FROM TBL_SONG WHERE ID_SONG = ?", Array(Array("id", CLng(Request("id")))))
'
' Los parámetros se pasan como: Array(Array("nombre1", valor1), ...)
' (o Nothing cuando la consulta no tiene parámetros).
' =====================================================================

Class PoliDB
    Private mConn

    Private Sub Class_Initialize()
        Set mConn = Server.CreateObject("ADODB.Connection")
        mConn.Open DB_CONNSTR
        mConn.CursorLocation = adUseClient
    End Sub

    Private Sub Class_Terminate()
        On Error Resume Next
        If Not mConn Is Nothing Then
            If mConn.State = 1 Then mConn.Close
        End If
        Set mConn = Nothing
    End Sub

    Public Property Get Connection()
        Set Connection = mConn
    End Property

    Private Function BuildCommand(sql, params)
        Dim cmd, i, p, v, pType, pSize
        Set cmd = Server.CreateObject("ADODB.Command")
        Set cmd.ActiveConnection = mConn
        cmd.CommandText = sql
        cmd.CommandType = adCmdText

        If IsArray(params) Then
            For i = LBound(params) To UBound(params)
                p = params(i)
                v = p(1)
                Select Case VarType(v)
                    Case vbInteger, vbLong, vbByte
                        pType = adInteger : pSize = 4
                    Case vbBoolean
                        pType = adBoolean : pSize = 2
                    Case vbDate
                        pType = adDate : pSize = 8
                    Case vbNull, vbEmpty
                        pType = adVarWChar : pSize = 4000 : v = Null
                    Case Else
                        pType = adVarWChar : pSize = 4000 : v = CStr(v)
                End Select
                cmd.Parameters.Append cmd.CreateParameter(CStr(p(0)), pType, adParamInput, pSize, v)
            Next
        End If

        Set BuildCommand = cmd
    End Function

    Public Function Scalar(sql, params)
        Dim rs, result
        Set rs = Me.Recordset(sql, params)
        If rs Is Nothing Then
            Scalar = Null
        ElseIf Not rs.EOF Then
            result = rs.Fields(0).Value
            If IsNull(result) Then Scalar = Null Else Scalar = result
        Else
            Scalar = Null
        End If
        On Error Resume Next
        rs.Close
        On Error GoTo 0
    End Function

    Public Function Execute(sql, params)
        Dim cmd, rs, affected
        Set cmd = BuildCommand(sql, params)
        Set rs = cmd.Execute(affected)
        If Not rs Is Nothing Then
            On Error Resume Next
            rs.Close
            On Error GoTo 0
        End If
        Execute = CLng(affected)
    End Function

    Public Function Recordset(sql, params)
        Dim cmd, rs
        Set cmd = BuildCommand(sql, params)
        Set rs = Server.CreateObject("ADODB.Recordset")
        rs.CursorLocation = adUseClient
        rs.Open cmd, , 0, 1   ' adOpenForwardOnly, adLockReadOnly
        Set Recordset = rs
    End Function
End Class

Function DB()
    Set DB = New PoliDB
End Function
%>
