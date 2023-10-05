// file: Ex5_FileReadAsync.prg
// An example for reading a large file with an async reader
// Compile with /start:Main

using System.Diagnostics
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
	  var sw := StopWatch{}
	  sw:Start()
      // the call is not awaited so a task object is returned
      var t := GetFile(filePath)
      ?i"Current task status: {t.Status}"
	  // wait for the task to complete
      t:Wait()
	  sw:Stop()
	  var duration := sw:Elapsed
      ?i"{t.Result.ToString(""n0"")} bytes read in {duration}"
      ?i"Current task status: {t.Status}"

End Class
