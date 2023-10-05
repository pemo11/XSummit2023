// file: Ex0_SyncVsAsyncA.prg
// Sync versus async, blocking versus non blocking
// compile with /main:App

using System.Threading.Tasks

Class App
   
   Async Static Method Operation1() As Task
      ? "Starting operation 1..."
      // do not use Thread.Sleep() anymore
      Await Task.Delay(3000)
      ? "Finished operation 1..."
      
   Async Static Method Operation2() As Task
      ? "Starting operation 2..."
      Await Task.Delay(2000)
      ? "Finished operation 2..."

   Async Static Method Operation3() As Task
      ? "Starting operation 3..."
      Await Task.Delay(1000)
      ? "Finished operation 3..."
      
   Static Method Start() As Void
      var t1 := Operation1()
      var t2 := Operation2()
      var t3 := Operation3()
      // Now wait for the completion of all tasks
      Task.WaitAll(<Task>{t1,t2,t3})
      
End Class
            