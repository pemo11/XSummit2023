// file: Ex_LongOperation_Async.prg
// A non blocking "long" operation
// compile with /main:App

using System.Threading.Tasks

Class App

    Async Static Method DoLongOperation() As Task
       await Task.Run(Async Delegate {
          For Local i := 1 UpTo 10
           ?i"Doing some work... ({i})"
           await Task.Delay(1000)
          Next
       })
       Return

    Async Static Method Start() As Task
       ? "Starting..."
       var t := DoLongOperation()
       ? "Doing another work..."
       await t
       ? "Finish..."
       Return
        

End Class