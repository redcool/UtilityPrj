Function RegReplace(rng As Range, p As String, c As String)
Dim regEx As Object
Set regEx = CreateObject("vbscript.regexp")
  With regEx
    .Global = True
    .Pattern = p
  End With
RegReplace = regEx.Replace(rng, c)
End Function