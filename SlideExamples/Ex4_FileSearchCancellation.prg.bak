// file: Ex4_FileSearchCancellation.prg
// An async file search with Cancellation
// compile with /t:winexe

using System.Collections.Generic
using System.Drawing
using System.IO
using System.Linq
using System.Windows.Forms

using System.Threading
using System.Threading.Tasks

Class MainForm Inherit Form
    Private btnStart As Button
    Private btnCancel As Button
    Private grp1 As GroupBox
    Private lbl1 As Label
    Private lbl2 As Label
    Private lbl3 As Label
    Private lbl4 As Label
    Private txtDirectory As TextBox
    Private txtFilter As TextBox
    Private lstFiles As ListBox
    Private toolTip1 As Tooltip
    
    Private cts As CancellationTokenSource

    Private Method InitializeComponent() As Void
        Self:Text := "FileSearch with Cancellation option"
        Self:Size := Size{660,680}
        Self:Font := Font{"Arial", 16}

        Self:toolTip1 := Tooltip{}

        lbl1 := Label{}
        lbl1:Text := "Directory:"
        lbl1:Backcolor := Color.LightGray
        lbl1:Size := Size{120,24}
        lbl1:Location := Point{20,8}

        txtDirectory := TextBox{}
        txtDirectory:Text := "D:\2023"
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

        grp1 := GroupBox{}
        grp1:Size := Size{400, 64}
        grp1:Location := Point{20, 122}
        
        btnStart := Button{}
        btnStart:Name := "btnStart"
        btnStart:Text := "&Search"
        btnStart:Size := Size{160,32}
        btnStart:Location := Point{20,20}

        btnCancel := Button{}
        btnCancel:Name := "btnCancel"
        btnCancel:Text := "&Cancel"
        btnCancel:Size := Size{160,32}
        btnCancel:Location := Point{200,20}

        grp1:Controls:AddRange(<Control>{btnStart, btnCancel})
        
        lbl3 := Label{}
        lbl3:Text := "Results:"
        lbl3:Size := Size{120,24}
        lbl3:Location := Point{20,192}
        lbl3:Backcolor := Color.LightBlue

        lstFiles := ListBox{}
        lstFiles:Size := Size{620,370}
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

        btnStart:Click += EventHandler{btnStart_Click}
        btnCancel:Click += EventHandler{btnCancel_Click}

        btnCancel:Enabled := False


    Constructor()
      InitializeComponent()

    Method ListDirectory(DirPath As String, Filter As String) As List<String>
        Return Directory.EnumerateFiles(DirPath, Filter):ToList()
    
    Method ListDirectories(DirPath As String, Filter As String, lb As Listbox, Token As CancellationToken) As Void
        Var files := ListDirectory(DirPath, Filter)
        If files:Count > 0
          lb:Items:AddRange(files:ToArray())
          lb:SelectedIndex := lb:Items:Count - 1
        EndIf
        ForEach var subdir in Directory.EnumerateDirectories(DirPath)
          If cts:Token:IsCancellationRequested
            cts:Token:ThrowIfCancellationRequested()
          EndIf
          ListDirectories(subdir, Filter, lb, Token)
        Next
        
    Async Method FileSearch(StartDirectory As String, FileFilter As String, lb As Listbox, Token As CancellationToken) As Task
        Local infoMsg As String
        await Task.Run({ => 
           Try
              ListDirectories(StartDirectory, FileFilter, lb, Token)
           Catch ex As OperationCanceledException 
              infoMsg := i"!!! {ex:Message}"
              lstFiles:Items:Add(infoMsg)
              lstFiles:SelectedIndex := lstFiles:Items:Count - 1
              btnStart:Enabled := True
              btnCancel:Enabled := False
           Catch ex As SystemException
              infoMsg := i"!!! error {ex:Message}"
              lstFiles:Items:Add(infoMsg)
              lstFiles:SelectedIndex := lstFiles:Items:Count - 1
           End Try
        }, token).ContinueWith({t =>
            lbl4:Text := i"{lstFiles.Items.Count} files listed"
        })
       
    Async Method btnStart_Click(Sender As Object, e As EventArgs) As Void
        btnStart:Enabled := False
        btnCancel:Enabled := True
        lbl4:Text := ""
        lstFiles:Items:Clear()
        cts := CancellationTokenSource{}
        await FileSearch(txtDirectory:Text, txtFilter:Text, lstFiles, cts:Token)
        btnStart:Enabled := True
        btnCancel:Enabled := False
 
    Method btnCancel_Click(Sender As Object, e As EventArgs) As Void
      cts:Cancel()
      
End Class

Function Start() As Void
   Application.Run(MainForm{})