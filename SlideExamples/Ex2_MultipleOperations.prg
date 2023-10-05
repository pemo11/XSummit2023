// file: Ex2_MultipleOperations.prg
// compile with /main:App

using System.Threading
using System.Threading.Tasks

Class App
   
   Static Method Operation1() As Void
      ? "Starting operation 1..."
      Thread.Sleep(3000)
      ? "Finished operation 1..."
      
   Static Method Operation2() As Void
      ? "Starting operation 2..."
      Thread.Sleep(2000)
      ? "Finished operation 2..."

   Static Method Operation3() As Void
      ? "Starting operation 3..."
      Thread.Sleep(1000)
      ? "Finished operation 3..."
      
   Async Static Method Operation1A() As Task
      ? "Starting operation 1A..."
      // do not use Thread.Sleep() anymore
      Await Task.Delay(3000)
      ? "Finished operation 1A..."
      
   Async Static Method Operation2A() As Task
      ? "Starting operation 2A..."
      Await Task.Delay(2000)
      ? "Finished operation 2A..."

   Async Static Method Operation3A() As Task
      ? "Starting operation 3A..."
      Await Task.Delay(1000)
      ? "Finished operation 3A..."
      
   Static Method Start() As Void
      ? "First the sync operations..."
      Operation1()
      Operation2()
      Operation3()
      ? "And now the async operations..."
      var t1 := Operation1A()
      var t2 := Operation2A()
      var t3 := Operation3A()
      // Now wait for the completion of all tasks
      Task.WaitAll(<Task>{t1,t2,t3})
      
End Class
            
