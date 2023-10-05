// file: Ex1_FileSearchBeginInvoke.prg
// A generic file search with/without BeginInvokeA
// compile with /t:winexe

using System.Collections.Generic
using System.Drawing
using System.IO
using System.LINQ
using System.Threading
using System.Windows.Forms

using System.Runtime.Remoting.Messaging 

Delegate dSearchDel (p1 as String, p2 As String) As List<FileInfo>

Class MainForm Inherit Form
    Private btnStart1 As Button
    Private btnStart2 As Button
	Private grp1 As GroupBox
    Private lbl1 As Label
    Private lbl2 As Label
    Private lbl3 As Label
    Private lbl4 As Label
    Private txtDirectory As TextBox
    Private txtFilter As TextBox
    Private lstFiles As ListBox
    Private toolTip1 As Tooltip

    Private Method InitializeComponent() As Void
        Self:Text := "FileSearch - sync vs async"
        Self:Size := Size{640,680}
        Self:Font := Font{"Arial", 16}

        Self:toolTip1 := Tooltip{}

        lbl1 := Label{}
        lbl1:Text := "Directory:"
        lbl1:Backcolor := Color.LightGray
        lbl1:Size := Size{120,24}
        lbl1:Location := Point{20,8}

        txtDirectory := TextBox{}
        txtDirectory:Text := "G:\2023"
        txtDirectory:Size := Size{320,24}
        txtDirectory:Location := Point{20,32}

        lbl2 := Label{}
        lbl2:Text := "Filter:"
        lbl2:Backcolor := Color.LightGreen
        lbl2:Size := Size{120,24}
        lbl2:Location := Point{20,68}

        txtFilter := TextBox{}
        txtFilter:Text := ".prg"
        txtFilter:Size := Size{120,24}
        txtFilter:Location := Point{20,92}

        grp1 := GroupBox{}
		grp1:Size := Size{400,80}
		grp1:Location := Point{20, 120}
		
        btnStart1 := Button{}
        btnStart1:Name := "btnStart1"
        btnStart1:Text := "&Search sync"
        btnStart1:Size := Size{160,32}
        btnStart1:Location := Point{20,30}

        btnStart2 := Button{}
        btnStart2:Name := "btnStart2"
        btnStart2:Text := "&Search async"
        btnStart2:Size := Size{160,32}
        btnStart2:Location := Point{220,30}

		grp1:Controls:AddRange(<Control>{btnStart1, btnStart2})
		
        lbl3 := Label{}
        lbl3:Text := "Results:"
        lbl3:Size := Size{120,24}
        lbl3:Location := Point{20,172}
        lbl3:Backcolor := Color.LightBlue

        lstFiles := ListBox{}
        lstFiles:Size := Size{600,380}
        lstFiles:Location := Point{20,220}
        lstFiles:Backcolor := Color.LightYellow
        lstFiles:Font := Font{"Arial", 12}
        lstFiles:HorizontalScrollbar := True
        lstFiles:SelectedIndexChanged += {sender, e => 
          Self:toolTip1:SetToolTip(lstFiles,lstFiles:SelectedItem:ToString())
        }

        lbl4 := Label{}
        lbl4:Text := ""
        lbl4:Backcolor := Color.Coral
        lbl4:Size := Size{200,24}
        lbl4:Location := Point{20,600}

        Self:Controls:AddRange(<Control>{grp1,lbl1,lbl2,lbl3,lbl4,txtFilter,txtDirectory,lstFiles})

        btnStart1:Click += EventHandler{btnStart1_Click}
        btnStart2:Click += EventHandler{btnStart2_Click}

        lstFiles:Items:Add(i"*** Thread-ID: {Thread.CurrentThread.ManagedThreadId}")

    Constructor()
      InitializeComponent()

    Method SearchFiles(StartDirectory As String, FileFilter As String) As List<FileInfo>
     Local dirFiles := Null As List<FileInfo>
      try
          var dirInfo := DirectoryInfo{StartDirectory}
          dirFiles := dirInfo:GetFiles("*", SearchOption.AllDirectories):Where({f => f:Extension == FileFilter}):ToList()
      Catch ex As SystemException
         var infoMsg := i"!!! error {ex:Message}"
         lstFiles:Items:Add(infoMsg)
         lstFiles:SelectedIndex := lstFiles:Items:Count - 1
      End Try
      Return dirFiles

    Method btnStart1_Click(Sender As Object, e As EventArgs) As Void
       btnStart1:Enabled := False
       lstFiles:Items:Clear()
       var resultFiles := SearchFiles(txtDirectory:Text, txtFilter:Text)
       var fileNames := resultFiles:Select({ f => f:FullName}):ToArray()
       lstFiles:Items:AddRange(fileNames)
       lbl4:Text := i"{Self.lstFiles.Items.Count} files listed"
       btnStart1:Enabled := True

    Method btnStart2_Click(Sender As Object, e As EventArgs) As Void
		btnStart2:Enabled := False
		lstFiles:Items:Clear()
		var dSearch := dSearchDel{SearchFiles}
		var AResult := dSearch:BeginInvoke(txtDirectory:Text, txtFilter:Text, AsyncCallback{FileSearchFinished},null)
		// could wait for the method to end
		// AResult:AsyncWaitHandle:WaitOne()
		
	Method FileSearchFinished(ar As IAsyncResult) As Void
		Local result := (AsyncResult)ar As AsyncResult
		Local dSearch := (dSearchDel) result:AsyncDelegate As dSearchDel
		var resultFiles := dSearch:EndInvoke(result)
		var fileNames := resultFiles:Select({ f => f:FullName}):ToArray()
		lstFiles:Items:AddRange(fileNames)
		lbl4:Text := i"{Self.lstFiles.Items.Count} files listed"
		btnStart2:Enabled := True

End Class


Function Start() As Void
   Application.Run(MainForm{})