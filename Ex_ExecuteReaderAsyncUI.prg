// file: Ex_ExecuteReaderAsyncUI.prg
// A asynchronously database access 
// compile with /t:winexe /r:System.Data.Sqlite.dll

using System.Collections.Generic
using System.Drawing
using System.Data
Using System.Data.Sqlite
using System.Windows.Forms

using System.Threading
using System.Threading.Tasks

Class MainForm Inherit Form
    Private btnSync As Button
    Private btnASync As Button
    Private lstStatus As ListBox
    Private dgvData As DataGridView
    Private grp1 As GroupBox
    Private Static thisForm As MainForm
    
    Private Method InitializeComponent() As Void
        thisForm := Self
        Self:Text := "Sync vs Async Database Access"
        Self:Size := Size{640,640}
        Self:Font := Font{"Arial", 16}

        grp1 := GroupBox{}
        grp1:Text := "Sync vs Async"
        grp1:Size := Size{500, 80}
        grp1:Location := Point{40,20}
        
        btnSync := Button{}
        btnSync:Name := "btnSync"
        btnSync:Text := "&Sync"
        btnSync:Size := Size{160,32}
        btnSync:Location := Point{20,30}
        
        btnAsync := Button{}
        btnAsync:Name := "btnAsync"
        btnAsync:Text := "&Async"
        btnAsync:Size := Size{160,32}
        btnAsync:Location := Point{200,30}

        grp1:Controls:AddRange(<Button>{btnSync, btnAsync})
        
        lstStatus := ListBox{}
        lstStatus.BackColor := Color.Black
        lstStatus.ForeColor := Color.LightYellow
        lstStatus:Size := Size{500,120}
        lstStatus:Location := Point{40,120}
        lstStatus:Font := Font{Self:Font:FontFamily,10}
        
        dgvData := DataGridView{}
        dgvData:Size := Size{500,400}
        dgvData:Location := Point{40,220}
        
        Self:Controls:AddRange(<Control>{grp1,lstStatus, dgvData})

        btnSync:Click += EventHandler{btnSync_Click}
        btnAsync:Click += EventHandler{btnAsync_Click}


    Constructor()
      InitializeComponent()

    Method btnSync_Click(Sender As Object, e As EventArgs) As Void
      dgvData:DataSource := Null
      var sqlText := "Select * From Book"
      UpdateStatus("Starting query")
      var ta := GetDataSync(sqlText)
      dgvData:DataSource := ta
      UpdateStatus("Query is finished")
      Return

    Async Method btnAsync_Click(Sender As Object, e As EventArgs) As Void
      dgvData:DataSource := Null
      var sqlText := "Select * From Book"
      UpdateStatus("Starting query")
      var ta := await GetDataAsync(sqlText)
      UpdateStatus("Query is finished")
      dgvData:DataSource := ta
      Return

    Private Method UpdateStatus(msg As String) As Void
       lstStatus:Items:Add(msg)
       lstStatus:SelectedIndex := lstStatus:Items:Count - 1
       
    Static Method GetDataSync(sql As String) As DataTable
     var cnStr := "Data Source=BookLib.db3"
     var ta := DataTable{}
     Begin using var cn := SqliteConnection{cnStr}
       cn:Open()
       var cmd := cn:CreateCommand()
       cmd:CommandText := sql
       ThisForm.UpdateStatus("Sync query started...")
       Begin Using var reader := cmd:ExecuteReader()
           ta:Load(reader)
       End Using
       ThisForm.UpdateStatus("Sync query finished...")
     End Using
     // A little delay as usual;)
     System.Threading.Thread.Sleep(2000)
     Return ta
 
    Async Static Method GetDataAsync(sql As String) As Task<DataTable>
     var cnStr := "Data Source=BookLib.db3"
     var ta := DataTable{}
     Begin using var cn := SqliteConnection{cnStr}
       cn:Open()
       var cmd := cn:CreateCommand()
       cmd:CommandText := sql
       ThisForm.UpdateStatus("Async query started...")
       Begin Using var reader := await cmd:ExecuteReaderAsync()
           ta:Load(reader)
       End Using
     End Using
     ThisForm.UpdateStatus("Async query finished...")
     // A little delay as usual;)
     await Task.Delay(2000)
     Return ta

End Class


Function Start() As Void
   Application.Run(MainForm{})