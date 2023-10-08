// file: Ex_FindPrimesMultitask.prg
// Finding prime numbers asynchronously with multiple tasks

using System.Collections.Generic
using System.Diagnostics
using System.Drawing
using System.Linq
using System.Threading
using System.Threading.Tasks
using System.Windows.Forms

Class MainForm Inherit Form
    Private btnStart As Button
    Private lbl1 As Label
    Private lbl2 As Label
    Private lbl3 As Label
    Private grp1 As GroupBox
    Private txtLowerBound As TextBox
    Private txtUpperBound As TextBox
    Private lstNumbers As ListBox
    Private PartitionCount := 4 As Int

    Private Method InitializeComponent() As Void
        Self:Text := "Find primes asynchronously with multiple tasks"
        Self:Size := Size{440,600}
        Self:Font := Font{"Arial", 16}

        Self:grp1 := GroupBox{}
        grp1:Size := Size{380, 120}
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
        btnStart:Location := Point{120,150}

        lstNumbers := ListBox{}
        lstNumbers:Size := Size{380,320}
        lstNumbers:Location := Point{20,200}
        lstNumbers:Backcolor := Color.LightYellow

        lbl3 := Label{}
        lbl3:Text := "0"
        lbl3:Backcolor := Color.Coral
        lbl3:Font := Font{"Arial", 12}
        lbl3:Size := Size{380,24}
        lbl3:Location := Point{20,520}

        Self:Controls:AddRange(<Control>{btnStart, grp1, lstNumbers, lbl3})

        btnStart:Click += EventHandler{btnStart_Click}

        lstNumbers:Items:Add(i"*** Thread-ID: {Thread.CurrentThread.ManagedThreadId}")

    Constructor()
      InitializeComponent()

   
    Private Method FindPrimeNumbers(l As Long, u As Long) As List<Long>
      var primes := List<Long>{}
      var m := l,n := u
      While m < n
        var b := (Long)2
        var foundPrime := True
        While b * b <= m
          If m % b == 0
             foundPrime := False
             exit
          EndIf
          b++
       End While
       If foundPrime
          primes:Add(m)
       EndIf
       m++
    End While
    Return primes
    
    Method btnStart_Click(Sender As Object, e As EventArgs) As Void
        btnStart:Enabled := False
        lstNumbers:Items:Clear()
        lbl3:Text := ""
        var l := Int32.Parse(txtLowerBound:Text)
        var u := Int32.Parse(txtUpperBound:Text)
        // partition the number range in multipe partitions (for example)
        Var partCount := (Int)(u - l) / PartitionCount
        Var partRemainder := (u - l) % PartitionCount
        var taskList := List<Task<List<Int>>>{}
        var sw := StopWatch{}
        sw:Start()
        For Var i := 0 Upto PartitionCount - 1
          var lPart := i * partCount + 1
          var uPart := lPart + partCount
          taskList:Add(Task.Run({=> FindPrimeNumbers(lPart, uPart)}))
        Next
        var lRemainder := u - partRemainder
        taskList:Add(Task.Run({=> FindPrimeNumbers(lRemainder, u)}))
        Task.WaitAll(taskList:ToArray())
        lstNumbers:Items:Add("Doing some other work...")
        var primes := List<Int>{}
        ForEach var t in taskList
           primes:AddRange(t:Result)
        Next
        sw:Stop()
        var duration := sw:elapsed
        lstNumbers:Items:AddRange(primes:Cast<Object>():ToArray())
        lstNumbers:SelectedIndex := lstNumbers:Items:Count - 1
        lbl3:Text := i"{primes.Count.ToString(""n0"")} primes found in {duration.TotalMilliseconds.ToString(""n2"")}ms"
        btnStart:Enabled := True
 
End Class


Function Start() As Void
   Application.Run(MainForm{})