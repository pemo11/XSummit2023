// file: Ex4_FileSearchCancellation.prg
// An async file search with Cancellation
// compile with /t:winexe

USING System.Collections.Generic
USING System.Drawing
USING System.IO
USING System.Linq
USING System.Windows.Forms

USING System.Threading
USING System.Threading.Tasks

CLASS MainForm INHERIT Form
    PRIVATE btnStart AS Button
    PRIVATE btnCancel AS Button
    PRIVATE grp1 AS GroupBox
    PRIVATE lbl1 AS Label
    PRIVATE lbl2 AS Label
    PRIVATE lbl3 AS Label
    PRIVATE lbl4 AS Label
    PRIVATE txtDirectory AS TextBox
    PRIVATE txtFilter AS TextBox
    PRIVATE lstFiles AS ListBox
    PRIVATE toolTip1 AS Tooltip
    
    PRIVATE cts AS CancellationTokenSource

    PRIVATE METHOD InitializeComponent() AS VOID
        SELF:Text := "FileSearch with Cancellation option"
        SELF:Size := Size{660,680}
        SELF:Font := Font{"Arial", 16}

        SELF:toolTip1 := Tooltip{}

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
        lstFiles:HorizontalScrollbar := TRUE
        lstFiles:SelectedIndexChanged += {sender, e => 
          SELF:toolTip1:SetToolTip(lstFiles,lstFiles:SelectedItem:ToString())
        }

        lbl4 := Label{}
        lbl4:Text := ""
        lbl4:Backcolor := Color.Coral
        lbl4:Size := Size{200,24}
        lbl4:Location := Point{20,600}

        SELF:Controls:AddRange(<Control>{grp1,lbl1,lbl2,lbl3,lbl4,txtFilter,txtDirectory,lstFiles})

        btnStart:Click += EventHandler{btnStart_Click}
        btnCancel:Click += EventHandler{btnCancel_Click}

        btnCancel:Enabled := FALSE


    CONSTRUCTOR()
      InitializeComponent()

    METHOD ListDirectory(DirPath AS STRING, Filter AS STRING) AS List<STRING>
        RETURN Directory.EnumerateFiles(DirPath, Filter):ToList()
    
    METHOD ListDirectories(DirPath AS STRING, Filter AS STRING, lb AS Listbox, Token AS CancellationToken) AS VOID
        VAR files := ListDirectory(DirPath, Filter)
        IF files:Count > 0
          lb:Items:AddRange(files:ToArray())
          lb:SelectedIndex := lb:Items:Count - 1
        ENDIF
        FOREACH VAR subdir IN Directory.EnumerateDirectories(DirPath)
          IF cts:Token:IsCancellationRequested
            cts:Token:ThrowIfCancellationRequested()
          ENDIF
          ListDirectories(subdir, Filter, lb, Token)
        NEXT
        
    ASYNC METHOD FileSearch(StartDirectory AS STRING, FileFilter AS STRING, lb AS Listbox, Token AS CancellationToken) AS Task
        LOCAL infoMsg AS STRING
        AWAIT Task.Run({ => 
           TRY
              ListDirectories(StartDirectory, FileFilter, lb, Token)
           CATCH ex AS OperationCanceledException 
              infoMsg := i"!!! {ex:Message}"
              lstFiles:Items:Add(infoMsg)
              lstFiles:SelectedIndex := lstFiles:Items:Count - 1
              btnStart:Enabled := TRUE
              btnCancel:Enabled := FALSE
           CATCH ex AS SystemException
              infoMsg := i"!!! error {ex:Message}"
              lstFiles:Items:Add(infoMsg)
              lstFiles:SelectedIndex := lstFiles:Items:Count - 1
           END TRY
        }, token).ContinueWith({t =>
            lbl4:Text := i"{lstFiles.Items.Count.ToString(""n0"")} files listed"
        })
       
    ASYNC METHOD btnStart_Click(Sender AS OBJECT, e AS EventArgs) AS VOID
        btnStart:Enabled := FALSE
        btnCancel:Enabled := TRUE
        lbl4:Text := ""
        lstFiles:Items:Clear()
        cts := CancellationTokenSource{}
        AWAIT FileSearch(txtDirectory:Text, txtFilter:Text, lstFiles, cts:Token)
        btnStart:Enabled := TRUE
        btnCancel:Enabled := FALSE
 
    METHOD btnCancel_Click(Sender AS OBJECT, e AS EventArgs) AS VOID
      cts:Cancel()
      
END CLASS

FUNCTION Start() AS VOID
   Application.Run(MainForm{})
