// file: UIFreeze_Solved.prg
// a simple example for a typical solved "UI Freeze" by using async/await
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
    PRIVATE lstNumbers AS ListBox

    PRIVATE METHOD GetNumbers() As List<Int>
        VAR numbers := List<Int>{}
        FOR var i := 1 UPTO 20
          numbers:Add(i)
          Thread.Sleep(100)
        NEXT
        RETURN numbers

    PRIVATE METHOD AddNumbers(lb As ListBox) As Void
        FOR var i := 1 UPTO 20
          lb:Items:Add(i)
          Thread.Sleep(100)
        NEXT

    ASYNC PRIVATE METHOD AddNumbers2(lb As ListBox) As Void
        FOR var i := 1 UPTO 20
          lb:Items:Add(i)
          Await Task.Delay(200)
        NEXT
        
    PRIVATE METHOD InitializeComponent() AS VOID
        SELF:Text := "The UI freeze solved"
        SELF:Size := Size{360,400}
        SELF:Font := Font{"Arial", 16}
        
        btnStart := Button{}
        btnStart:Name := "btnStart"
        btnStart:Text := "&Start"
        btnStart:Size := Size{160,32}
        btnStart:Location := Point{80,20}
        
        lstNumbers := ListBox{}
        lstNumbers:Size := Size{160,280}
        lstNumbers:Location := Point{80,80}
        lstNumbers:Backcolor := Color.LightYellow

        SELF:Controls:AddRange(<Control>{btnStart,lstNumbers})

        btnStart:Click += EventHandler{btnStart_Click}

    CONSTRUCTOR()
      InitializeComponent()

    ASYNC METHOD btnStart_Click(Sender AS OBJECT, e AS EventArgs) AS VOID
        btnStart:Enabled := FALSE
        lstNumbers:Items:Clear()
        // var numbers := GetNumbers()
        // AWAIT Task.Run({ => AddNumbers(lstNumbers) })
        AWAIT Task.Run({ => AddNumbers2(lstNumbers) })
        // lstNumbers:Items:AddRange(numbers:Cast<Object>():ToArray())
        btnStart:Enabled := TRUE
        lstNumbers:SelectedIndex := lstNumbers:Items:Count - 1

END CLASS

FUNCTION Start() AS VOID
   Application.Run(MainForm{})