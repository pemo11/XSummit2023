// file: Ex_FileSearchV2_Sync.prg
// A synchronously file search that is done recursively
// compile with /t:winexe

using System.Drawing
using System.IO
using System.Windows.Forms
using System.Threading

Class MainForm Inherit Form
    Private btnStart As Button
    Private lbl1 As Label
    Private lbl2 As Label
    Private lbl3 As Label
    Private lbl4 As Label
    Private txtDirectory As TextBox
    Private txtFilter As TextBox
    Private lstFiles As ListBox
    Private toolTip1 As Tooltip

    Private Method InitializeComponent() As Void
        Self:Text := "FileSearch - Synchronous V2"
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
        txtFilter:Text := "*.prg"
        txtFilter:Size := Size{120,24}
        txtFilter:Location := Point{20,92}

        btnStart := Button{}
        btnStart:Name := "btnStart"
        btnStart:Text := "&Search"
        btnStart:Size := Size{160,32}
        btnStart:Location := Point{20,132}

        lbl3 := Label{}
        lbl3:Text := "Results:"
        lbl3:Size := Size{120,24}
        lbl3:Location := Point{20,172}
        lbl3:Backcolor := Color.LightBlue

        lstFiles := ListBox{}
        lstFiles:Size := Size{600,420}
        lstFiles:Location := Point{20,200}
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

        Self:Controls:AddRange(<Control>{btnStart,lbl1,lbl2,lbl3,lbl4,txtFilter,txtDirectory,lstFiles})

        btnStart:Click += EventHandler{btnStart_Click}

        lstFiles:Items:Add(i"*** Thread-ID: {Thread.CurrentThread.ManagedThreadId}")

    Constructor()
      InitializeComponent()

    Method ListFiles(dirInfo As DirectoryInfo, FileFilter As String) As Void
       try
         var dirFiles := dirInfo:GetFiles(FileFilter)
         ForEach var fi in dirFiles
            lstFiles:Items:Add(fi:FullName)
            lstFiles:SelectedIndex := lstFiles:Items:Count - 1
         Next
         ForEach var dir in dirInfo:GetDirectories()
            var subDirInfo := DirectoryInfo{dir:FullName}
	          ListFiles(subDirInfo, FileFilter)
         Next
      Catch ex As SystemException
         var infoMsg := i"!!! error {ex:Message}"
         lstFiles:Items:Add(infoMsg)
         lstFiles:SelectedIndex := lstFiles:Items:Count - 1
      End Try

    Method FileSearch(StartDirectory As String, FileFilter As String) As Void
       var dirInfo := DirectoryInfo{StartDirectory}
       lstFiles:Items:Clear()
       ListFiles(dirInfo, FileFilter)

    Method btnStart_Click(Sender As Object, e As EventArgs) As Void
       btnStart:Enabled := False
       FileSearch(txtDirectory:Text, txtFilter:Text)
       lbl4:Text := i"{Self.lstFiles.Items.Count} files listed"
       btnStart:Enabled := True
 
End Class


Function Start() As Void
   Application.Run(MainForm{})