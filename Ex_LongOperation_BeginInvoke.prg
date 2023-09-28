// file: Ex_LongOperation_BeginInvoke.prg
// A blocking "long" operation run async the old style way
// compile with /main:App

Delegate d1 (n As Int) As Void

Class App

    Static Method DoLongOperation(n As Int) As Void
       For Local i := 1 UpTo n
           ?i"Doing some work... ({i})"
           System.Threading.Thread.Sleep(1000)
       Next
       Return

    Static Method LongOpFinished(ar As IAsyncResult) As Void
       ? "Finish..."
    
    Static Method Start() As Void
       ? "Starting..."
       var d1Del := d1{DoLongOperation}
       var AResult := d1Del:BeginInvoke(12, AsyncCallback{LongOpFinished},null)
       ? "Doing another work..."
       AResult:AsyncWaitHandle:WaitOne()
       Return

End Class