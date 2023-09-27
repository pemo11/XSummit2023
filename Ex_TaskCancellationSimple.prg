// file: Ex_TaskCancellationSimple.prg
// A vey simple example for the cancellation of a task
// compile with /main:App

using System.Threading
using System.Threading.Tasks

Class App

  Static Method StartTask() As Task
    var cts := CancellationTokenSource{}
    var t := Task.Run(async Delegate {
        For Local i := 1 UpTo 10
          ? i"Looping the {i}th time..."
          await Task.Delay(1000)
          If i == 7
            cts:Cancel()
          EndIf
          If cts:Token:IsCancellationRequested
            cts:Token:ThrowIfCancellationRequested()
          EndIf
        Next
      }, cts:Token):ContinueWith({ task => 
        If task:IsCanceled
          ?"Zee task was cancelled prematurely!"
        EndIf
      })
      t:Wait()
    Return t

  Static Method Start() As Void
    StartTask()

End Class