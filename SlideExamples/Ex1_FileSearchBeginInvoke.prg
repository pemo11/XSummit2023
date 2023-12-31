// file: Ex1_FileSearchBeginInvoke.prg
// A generic file search with/without BeginInvokeA
// compile with /t:winexe

USING System.Collections.Generic
USING System.Drawing
USING System.IO
USING System.LINQ
USING System.Threading
USING System.Windows.Forms

USING System.Runtime.Remoting.Messaging 

DELEGATE dSearchDel (p1 AS STRING, p2 AS STRING) AS List<FileInfo>

CLASS MainForm INHERIT Form
    PRIVATE btnStart1 AS Button
    PRIVATE btnStart2 AS Button
	PRIVATE grp1 AS GroupBox
    PRIVATE lbl1 AS Label
    PRIVATE lbl2 AS Label
    PRIVATE lbl3 AS Label
    PRIVATE lbl4 AS Label
    PRIVATE txtDirectory AS TextBox
    PRIVATE txtFilter AS TextBox
    PRIVATE lstFiles AS ListBox
    PRIVATE toolTip1 AS Tooltip

    PRIVATE METHOD InitializeComponent() AS VOID
        SELF:Text := "FileSearch - sync vs async"
        SELF:Size := Size{640,680}
        SELF:Font := Font{"Arial", 16}

        SELF:toolTip1 := Tooltip{}

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

        btnStart1:Click += EventHandler{btnStart1_Click}
        btnStart2:Click += EventHandler{btnStart2_Click}

        lstFiles:Items:Add(i"*** Thread-ID: {Thread.CurrentThread.ManagedThreadId}")

    CONSTRUCTOR()
      InitializeComponent()

    METHOD SearchFiles(StartDirectory AS STRING, FileFilter AS STRING) AS List<FileInfo>
     LOCAL dirFiles := NULL AS List<FileInfo>
      TRY
          VAR dirInfo := DirectoryInfo{StartDirectory}
          dirFiles := dirInfo:GetFiles("*", SearchOption.AllDirectories):Where({f => f:Extension == FileFilter}):ToList()
      CATCH ex AS SystemException
         VAR infoMsg := i"!!! error {ex:Message}"
         lstFiles:Items:Add(infoMsg)
         lstFiles:SelectedIndex := lstFiles:Items:Count - 1
      END TRY
      RETURN dirFiles

    METHOD btnStart1_Click(Sender AS OBJECT, e AS EventArgs) AS VOID
       btnStart1:Enabled := FALSE
       lstFiles:Items:Clear()
       VAR resultFiles := SearchFiles(txtDirectory:Text, txtFilter:Text)
       VAR fileNames := resultFiles:Select({ f => f:FullName}):ToArray()
       lstFiles:Items:AddRange(fileNames)
       lbl4:Text := i"{Self.lstFiles.Items.Count} files listed"
       btnStart1:Enabled := TRUE

    METHOD btnStart2_Click(Sender AS OBJECT, e AS EventArgs) AS VOID
		btnStart2:Enabled := FALSE
		lstFiles:Items:Clear()
		VAR dSearch := dSearchDel{SearchFiles}
		VAR AResult := dSearch:BeginInvoke(txtDirectory:Text, txtFilter:Text, AsyncCallback{FileSearchFinished}, NULL)
		// could wait for the method to end
		// AResult:AsyncWaitHandle:WaitOne()
		
	METHOD FileSearchFinished(ar AS IAsyncResult) AS VOID
		LOCAL result := (AsyncResult)ar AS AsyncResult
		LOCAL dSearch := (dSearchDel) result:AsyncDelegate AS dSearchDel
		VAR resultFiles := dSearch:EndInvoke(result)
		VAR fileNames := resultFiles:Select({ f => f:FullName}):ToArray()
		lstFiles:Items:AddRange(fileNames)
		lbl4:Text := i"{Self.lstFiles.Items.Count} files listed"
		btnStart2:Enabled := TRUE

END CLASS


FUNCTION Start() AS VOID
   Application.Run(MainForm{})
