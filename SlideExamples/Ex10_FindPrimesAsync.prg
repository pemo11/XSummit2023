// file: Ex10_FindPrimesASync.prg
// Finding prime numbers asynchronously

USING System.Collections.Generic
USING System.Diagnostics
USING System.Drawing
USING System.Linq
USING System.Threading
USING System.Threading.Tasks
USING System.Windows.Forms

CLASS MainForm INHERIT Form
    PRIVATE btnStart AS Button
    PRIVATE lbl1 AS Label
    PRIVATE lbl2 AS Label
    PRIVATE lbl3 AS Label
    PRIVATE grp1 AS GroupBox
    PRIVATE txtLowerBound AS TextBox
    PRIVATE txtUpperBound AS TextBox
    PRIVATE lstNumbers AS ListBox

    PRIVATE METHOD InitializeComponent() AS VOID
        SELF:Text := "Find primes asynchronously"
        SELF:Size := Size{400,600}
        SELF:Font := Font{"Arial", 16}

        SELF:grp1 := GroupBox{}
        grp1:Size := Size{360, 100}
        grp1:Location := Point{20, 20}
        
        lbl1 := Label{}
        lbl1:Text := "Lower:"
        lbl1:Backcolor := Color.LightGray
        lbl1:Size := Size{100,24}
        lbl1:Location := Point{20,16}

        txtLowerBound := TextBox{}
        txtLowerBound:Text := "1"
        txtLowerBound:Size := Size{120,24}
        txtLowerBound:Location := Point{20,48}

        lbl2 := Label{}
        lbl2:Text := "Upper:"
        lbl2:Backcolor := Color.LightGray
        lbl2:Size := Size{100,24}
        lbl2:Location := Point{160,16}

        txtUpperBound := TextBox{}
        txtUpperBound:Text := "5000000"
        txtUpperBound:Size := Size{120,24}
        txtUpperBound:Location := Point{160,48}

        grp1:Controls:AddRange(<Control>{lbl1, lbl2, txtLowerBound, txtUpperBound})
        
        btnStart := Button{}
        btnStart:Name := "btnStart"
        btnStart:Text := "&Search"
        btnStart:Size := Size{160,32}
        btnStart:Location := Point{120,140}

        lstNumbers := ListBox{}
        lstNumbers:Size := Size{350,320}
        lstNumbers:Location := Point{20,200}
        lstNumbers:Backcolor := Color.LightYellow

        lbl3 := Label{}
        lbl3:Text := "0"
        lbl3:Backcolor := Color.Coral
        lbl3:Font := Font{"Arial", 12}
        lbl3:Size := Size{350,24}
        lbl3:Location := Point{20,520}

        SELF:Controls:AddRange(<Control>{btnStart, grp1, lstNumbers, lbl3})

        btnStart:Click += EventHandler{btnStart_Click}

        lstNumbers:Items:Add(i"*** Thread-ID: {Thread.CurrentThread.ManagedThreadId}")

    CONSTRUCTOR()
      InitializeComponent()

   
    PRIVATE METHOD FindPrimeNumbers(l AS LONG, u AS LONG) AS List<LONG>
      VAR primes := List<LONG>{}
      VAR m := l,n := u
      WHILE m < n
        VAR b := (LONG)2
        VAR foundPrime := TRUE
        WHILE b * b <= m
          IF m % b == 0
             foundPrime := FALSE
             EXIT
          ENDIF
          b++
       END WHILE
       IF foundPrime
          primes:Add(m)
       ENDIF
       m++
    END WHILE
    RETURN primes
    
    ASYNC METHOD btnStart_Click(Sender AS OBJECT, e AS EventArgs) AS VOID
        btnStart:Enabled := FALSE
        lstNumbers:Items:Clear()
        lbl3:Text := ""
        VAR l := Int32.Parse(txtLowerBound:Text)
        VAR u := Int32.Parse(txtUpperBound:Text)
        VAR sw := StopWatch{}
        sw:Start()
        // var primes := AWAIT Task.Run({=> FindPrimeNumbers(l, u)})
        VAR t := Task.Run({=> FindPrimeNumbers(l, u)})
        lstNumbers:Items:Add("Doing some other work...")
        VAR primes := AWAIT t
        sw:Stop()
        VAR duration := sw:elapsed
        lstNumbers:Items:AddRange(primes:Cast<OBJECT>():ToArray())
        lstNumbers:SelectedIndex := lstNumbers:Items:Count - 1
        lbl3:Text := i"{primes.Count.ToString(""n0"")} primes found in {duration.TotalMilliseconds.ToString(""n2"")}ms"
        btnStart:Enabled := TRUE
 
END CLASS


FUNCTION Start() AS VOID
   Application.Run(MainForm{})
