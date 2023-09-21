// file: Ex_LongOperation_Sync.prg
// A blocking "long" operation
// compile with /main:App

Class App

    Static Method DoLongOperation() As Void
       For Local i := 1 UpTo 10
           ?i"Doing some work... ({i})"
           System.Threading.Thread.Sleep(1000)
       Next
       Return

    Static Method Start() As Void
       ? "Starting..."
       DoLongOperation()
       ? "Doing another work..."
       ? "Finish..."
       Return

End Class