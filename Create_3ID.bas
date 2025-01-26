Attribute VB_Name = "Create_3ID"
Sub DSE3ID()
    Dim FileName As String
    Dim fileLoc As String
    Dim FileBaru As Workbook
    Dim ReportDate As String
    
    FileName = "KPI DSE 3ID "
    fileLoc = Left(ThisWorkbook.FullName, Len(ThisWorkbook.FullName) - Len(ThisWorkbook.Name))
    ReportDate = ThisWorkbook.Worksheets("Template Email 3ID").Range("Q3").Value
    
    'Create file baru
    Set FileBaru = Workbooks.Add
    
    'Save as
    ActiveWorkbook.SaveAs FileName:=fileLoc & FileName & ReportDate & ".xlsx"
    
    'Tambahin worksheet tambahan
    FileBaru.Worksheets.Add Count:=3
    
    'Rename Sheet Detail Detail Sitewise
    Worksheets("Sheet1").Name = "BM"
    
    'Copy range to clipboard
    ThisWorkbook.Worksheets("BM 3ID").Cells.Copy
    
    'Paste Value & Format
    FileBaru.Worksheets("BM").Activate
    FileBaru.Worksheets("BM").Cells.PasteSpecial Paste:=xlPasteValues
    FileBaru.Worksheets("BM").Cells.PasteSpecial Paste:=xlPasteFormats
    
    'Set Zoom ke 80% dan ilangin gridline
    ActiveWindow.Zoom = 80
    ActiveWindow.DisplayGridlines = False
    
    'Rename Sheet Detail XSell Reload
    Worksheets("Sheet2").Name = "SPV"
    
    'Copy range to clipboard
    ThisWorkbook.Worksheets("SPV 3ID").Cells.Copy
    
    'Paste Value & Format
    FileBaru.Worksheets("SPV").Activate
    FileBaru.Worksheets("SPV").Cells.PasteSpecial Paste:=xlPasteValues
    FileBaru.Worksheets("SPV").Cells.PasteSpecial Paste:=xlPasteFormats
    
    'Set Zoom ke 80% dan ilangin gridline
    ActiveWindow.Zoom = 80
    ActiveWindow.DisplayGridlines = False
    
    'Rename Sheet Detail Detail Sitewise
    Worksheets("Sheet3").Name = "DSE"
    
   ' Copy range A:AY dari worksheet yang ada di ThisWorkbook
    ThisWorkbook.Worksheets("DSE 3ID SEND").Cells.Copy
    
    ' Paste value & format ke worksheet yang baru
    FileBaru.Worksheets("DSE").Activate
    FileBaru.Worksheets("DSE").Cells.PasteSpecial Paste:=xlPasteValues
    FileBaru.Worksheets("DSE").Cells.PasteSpecial Paste:=xlPasteFormats
    
    ' Set Zoom ke 80% dan hilangkan gridlines
    ActiveWindow.Zoom = 80
    ActiveWindow.DisplayGridlines = False
    
    'Rename Sheet Detail Detail Sitewise
    Worksheets("Sheet4").Name = "SCORE SLAB"
    
    ThisWorkbook.Worksheets("SLAB 3ID").Activate
    ActiveSheet.Outline.ShowLevels RowLevels:=4
    
    'Copy range to clipboard
    ThisWorkbook.Worksheets("SLAB3ID_Create").Cells.Copy
    
    'Paste Value & Format
    FileBaru.Worksheets("SCORE SLAB").Activate
    FileBaru.Worksheets("SCORE SLAB").Cells.PasteSpecial Paste:=xlPasteValues
    FileBaru.Worksheets("SCORE SLAB").Cells.PasteSpecial Paste:=xlPasteFormats
    
    'Set Zoom ke 80% dan ilangin gridline
    ActiveWindow.Zoom = 80
    ActiveWindow.DisplayGridlines = False
    
    ' Tutup workbook baru dengan menyimpan
    FileBaru.Close SaveChanges:=True
End Sub
