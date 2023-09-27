// file: Ex_FileReadAsync.prg
// An example for reading a large file with an async reader
// Compile with /start:Main

using System.IO
using System.Threading.Tasks

Class App

  Static Async Method GetFile(FilePath As String) As Task<Int>
      Local buffer As Byte[]
      Local result As Int
      Begin Using var fs := File.Open(FilePath, FileMode.Open)
        buffer := byte[]{fs:Length}
        result := await fs:ReadAsync(buffer, 0, buffer:Length)
      End Using
      Return result
      
  Static Method Start() As Void
      var filePath := Path.Combine(Environment.CurrentDirectory, "LargeFile.txt")
      ? "Start reading..."
      // call is not awaited so a task object is returned
      var t := GetFile(filePath)
      ?i"Current task status: {t.Status}"
      // is Wait() optional ?
      // without Wait() the status is WaitingForActivation
      // by queyring the result, the task gets executed so the buffer size is queryable
      // t:Wait()
      ?i"{t.Result.ToString(""n0"")} bytes read"
      ?i"Current task status: {t.Status}"

End Class

/*
 RanToCompletion       - The task completed execution successfully
 WaitingForActivation  - The task is waiting to be activated and scheduled internally by the .NET infrastructure
 Running               - The task is running but has not yet completed
*/