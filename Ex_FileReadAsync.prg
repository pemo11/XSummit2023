// file: Ex_FileReadAsync.prg
// Example for reading a large file with an async reader
// compile with /main:App

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
    // Method is not awaited - so it returns a task object
    var t := GetFile(filePath)
    ? i"Current task status: {t.Status}"
    // t:Wait()
    ? i"Current task status: {t.Status}"
    ? i"Reading {t.Result.ToString(""n0"")} Bytes"

End Class
