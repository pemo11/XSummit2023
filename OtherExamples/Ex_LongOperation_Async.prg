// file: Ex_LongOperation_Async.prg
// A non blocking "long" operation
// compile with /main:App

using System.Threading.Tasks

Class App

    Async Static Method DoLongOperation(n As Int) As Task
       await Task.Run(Async Delegate {
          For Local i := 1 UpTo n
           ?i"Doing some work... ({i})"
           await Task.Delay(1000)
          Next
       })
       Return

    Async Static Method Start() As Task
       ? "Starting..."
       var t := DoLongOperation(12)
       ? "Doing another work..."
       await t
       ? "Finish..."
       Return

      // if there is no other work to do, the async call can be simplified
      // await DoLongOperation()

End Class