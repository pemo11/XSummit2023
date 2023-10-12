// file: Ex11_FindPrimesMultitask.prg
// Finding prime numbers asynchronously with multiple tasks

Using System.Collections.Generic
Using System.Diagnostics
Using System.Drawing
Using System.Linq
Using System.Threading
Using System.Threading.Tasks
Using System.Windows.Forms

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
        Var primes := List<Long>{}
        Var m := l,n := u
        While m < n
            Var b := (Long)2
            Var foundPrime := True
            While b * b <= m
                If m % b == 0
                    foundPrime := False
                    Exit
                Endif
                b++
            End While
            If foundPrime
                primes:Add(m)
            Endif
            m++
        End While
    Return primes
    
   Async Method btnStart_Click(Sender As Object, e As EventArgs) As Void
        btnStart:Enabled := False
        lbl3:Text := ""
        lstNumbers:Items:Clear()
        Var l := Int32.Parse(txtLowerBound:Text)
        Var u := Int32.Parse(txtUpperBound:Text)
        // partition the number range in multipe partitions (for example)
        Var partCount := (Int)(u - l) / PartitionCount
        Var partRemainder := (u - l) % PartitionCount
        Var taskList := List<Task<List<Int>>>{}
        lstNumbers:Items:Add("Getting prime numbers...")
        Var sw := StopWatch{}
        sw:Start()
        For Var i := 0 Upto PartitionCount - 1
          Var lPart := i * partCount + 1
            Var uPart := lPart + partCount
            taskList:Add(Task.Run({=> FindPrimeNumbers(lPart, uPart)}))
            Application.DoEvents()
        Next
        Var lRemainder := u - partRemainder
        taskList:Add(Task.Run({=> FindPrimeNumbers(lRemainder, u)}))
        // Not necessary when querying the result of each task?
        lstNumbers:Items:Add("Doing some other work...")
        // not good because blocking
        // Task.WaitAll(taskList:ToArray())
        // does not compile
        // Await taskList
        // Thanks to Stackoverflow;)
        Var result := Await Task.WhenAll(taskList)
        sw:Stop()
        Var primes := List<Int>{}
        // result is a list of lists
        Foreach Var l1 In result
            primes:AddRange(l1)
         Next
        Var duration := sw:elapsed
    	lstNumbers:Items:AddRange(primes:Cast<Object>():ToArray())
        lstNumbers:SelectedIndex := lstNumbers:Items:Count - 1
        lbl3:Text := i"{primes.Count.ToString(""n0"")} primes found in {duration.TotalMilliseconds.ToString(""n2"")}ms"
        btnStart:Enabled := True
        
   	/*
    Async Method btnStart_Click(Sender As Object, e As EventArgs) As Void
        btnStart:Enabled := False
        Var sw := StopWatch{}
        sw:Start()
        Var primes := Await Task.Run({ => 
            lbl3:Text := ""
            lstNumbers:Items:Clear()
            Var l := Int32.Parse(txtLowerBound:Text)
            Var u := Int32.Parse(txtUpperBound:Text)
            // partition the number range in multipe partitions (for example)
            Var partCount := (Int)(u - l) / PartitionCount
            Var partRemainder := (u - l) % PartitionCount
            Var taskList := List<Task<List<Int>>>{}
            For Var i := 0 Upto PartitionCount - 1
              Var lPart := i * partCount + 1
                Var uPart := lPart + partCount
                taskList:Add(Task.Run({=> FindPrimeNumbers(lPart, uPart)}))
            Next
            Var lRemainder := u - partRemainder
            taskList:Add(Task.Run({=> FindPrimeNumbers(lRemainder, u)}))
            // Not necessary when querying the result of each task?
            // Task.WaitAll(taskList:ToArray())
            lstNumbers:Items:Add("Doing some other work...")
            Var primes := List<Int>{}
            Foreach Var t In taskList
               primes:AddRange(t:Result)
            Next
            Return primes
        })
            sw:Stop()
            Var duration := sw:elapsed
        lstNumbers:Items:AddRange(primes:Cast<Object>():ToArray())
        lstNumbers:SelectedIndex := lstNumbers:Items:Count - 1
        lbl3:Text := i"{primes.Count.ToString(""n0"")} primes found in {duration.TotalMilliseconds.ToString(""n2"")}ms"
            btnStart:Enabled := True
      */

End Class


Function Start() As Void
   Application.Run(MainForm{})
