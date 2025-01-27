Attribute VB_Name = "SemdMail_3ID"
Sub KirimEmail3ID()

Dim OutApp As Object
Dim OutMail As Object
Dim FileName As String
Dim fileLoc As String
Dim ReportDate As String
Dim MakeJPG1 As String
Dim JPGName1 As String

Dim rg1 As Range
Dim strl1 As String
Dim strl2 As String
Dim strl3 As String
Dim strl4 As String
Dim strl5 As String
Dim strl6 As String
Dim strl7 As String
Dim strl8 As String
Dim strl9 As String
Dim strl10 As String
Dim strl11 As String
Dim strl12 As String
Dim strl13 As String
Dim strl14 As String
Dim strl15 As String
Dim strl16 As String

Dim Dest As Variant
Dim SDest As String
Dim iCounter As Integer

Dim Destcc As Variant
Dim SDestcc As String
Dim iCountercc As Integer

FileName = "KPI DSE 3ID "
fileLoc = Left(ThisWorkbook.FullName, Len(ThisWorkbook.FullName) - Len(ThisWorkbook.Name))
ReportDate = ThisWorkbook.Worksheets("Template Email 3ID").Range("Q3").Value

Set OutApp = CreateObject("outlook.application")
Set OutMail = OutApp.CreateItem(0)

Set rg1 = ThisWorkbook.Worksheets("SUMM").Range("B4:N15")
JPGName1 = "Image0013ID_" & ReportDate

MakeJPG1 = CopyRangeToJPG("SUMM", "B4:N15", JPGName1)

strl1 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N4").Value & "<br><br>"
strl2 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N6").Value & "<br><br>"
strl3 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N8").Value & "<br>"
strl4 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N9").Value & "<br>"
strl5 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N10").Value & "<br><br>"
strl6 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N12").Value & "<br>"
strl7 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N13").Value & "<br>"
strl8 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N14").Value & "<br>"
strl9 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N15").Value & "<br><br>"
strl10 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N17").Value & "<br>"
strl11 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N19").Value & "<br>"
strl12 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N20").Value & "<br>"
strl13 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N21").Value & "<br><br>"
strl14 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N23").Value & "<br>"
strl15 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N24").Value
strl16 = ThisWorkbook.Worksheets("Template Email 3ID").Range("N25").Value
strl17 = ThisWorkbook.Worksheets("Template Email 3ID").Range("P12").Value

    If MakeJPG1 = "" Then
        MsgBox "Something go wrong, we can't create the mail"
        With Application
            .EnableEvents = True
            .ScreenUpdating = True
        End With
        Exit Sub
    End If
    
On Error Resume Next
    With OutMail
        
        'Input semua alamat tujuan email
        SDest = ""
           For iCounter = 1 To ThisWorkbook.Worksheets("Template Email 3ID").Range("C1").Value
           If SDest = "" Then
               SDest = ThisWorkbook.Worksheets("Template Email 3ID").Range("B" & iCounter).Value
           Else
               SDest = SDest & ";" & ThisWorkbook.Worksheets("Template Email 3ID").Range("B" & iCounter).Value
           End If
        Next iCounter
        
        'Input semua alamat cc email
        SDestcc = ""
           For iCountercc = 1 To ThisWorkbook.Worksheets("Template Email 3ID").Range("G1").Value
           If SDestcc = "" Then
               SDestcc = ThisWorkbook.Worksheets("Template Email 3ID").Range("F" & iCountercc).Value
           Else
               SDestcc = SDestcc & ";" & ThisWorkbook.Worksheets("Template Email 3ID").Range("F" & iCountercc).Value
           End If
        Next iCountercc
        
        'Define basic info
        .To = SDest
        .CC = SDestcc
        .Subject = ThisWorkbook.Worksheets("Template Email 3ID").Range("N2").Value
        .Attachments.Add fileLoc & FileName & ReportDate & ".xlsx"
        .Attachments.Add MakeJPG1, 1, 0
        
        .Display
        
        'Display the email
        'Display the email
        .HTMLBody = "<html><div style='font:14.5px Indosat Regular'><p>" & strl1 & strl2 & _
            "<ol>" & _
                "<b><li>" & strl3 & "</li></b>" & _
                "<ol type='a'>" & _
                    "<li>" & strl4 & "</li>" & _
                    "<li>" & strl5 & "</li>" & _
                "</ol>" & _
                "<b><li>" & strl6 & "</li></b>" & _
                "<ol type='a'>" & _
                    "<li>" & strl7 & "</li>" & _
                    "<li>" & strl8 & "</li>" & _
                    "<li>" & strl9 & "</li>" & _
                "</ol>" & _
                "<b><li>" & strl10 & "</li></b>" & _
                "<img src='cid:" & JPGName1 & ".jpg' width='50%' height='auto'>" & "<br><br>" & _
            "</ol>" & _
        strl11 & strl12 & strl13 & strl14 & _
        strl15 & " " & _
        "<a href='" & strl17 & "' style='color:blue; text-decoration:none;'>" & strl16 & "</a>" & _
        "</p></div></html>"

    End With
    On Error GoTo 0
    
    With Application
        .EnableEvents = True
        .ScreenUpdating = True
    End With

Set OutMail = Nothing
Set OutApp = Nothing
        
End Sub


Function CopyRangeToJPG(NameWorksheet As String, RangeAddress As String, JPGName As String) As String
    'Ron de Bruin, 25-10-2019
    Dim PictureRange As Range
    Dim fileLoc As String
    
    'set lokasi untuk simpan image pada folder yang sama dengan excel
    fileLoc = ThisWorkbook.Path & "\"
    
    With ActiveWorkbook
        On Error Resume Next
        .Worksheets(NameWorksheet).Activate
        Set PictureRange = .Worksheets(NameWorksheet).Range(RangeAddress)
        
        If PictureRange Is Nothing Then
            MsgBox "Sorry this is not a correct range"
            On Error GoTo 0
            Exit Function
        End If
        
        PictureRange.CopyPicture
        With .Worksheets(NameWorksheet).ChartObjects.Add(PictureRange.Left, PictureRange.Top, PictureRange.Width, PictureRange.Height)
            .Activate
            .Chart.Paste
            .Chart.Export fileLoc & JPGName & ".jpg", "JPG"
        End With
        .Worksheets(NameWorksheet).ChartObjects(.Worksheets(NameWorksheet).ChartObjects.Count).Delete
    End With
    
    CopyRangeToJPG = fileLoc & JPGName & ".jpg"
    Set PictureRange = Nothing
End Function

