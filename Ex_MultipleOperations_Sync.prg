// file: Ex0_SyncVsAsyncS.prg
// Sync versus async, blocking versus non blocking
// compile with /main:App

using System.Threading

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
      
   Static Method Start() As Void
      Operation1()
      Operation2()
      Operation3()
      
End Class
            