// file: Ex_ExecuteReaderAsyncRight.prg
// Example for an asynchronous database query
// compile with /main:App /r:System.Data.Sqlite.dll

Using System.Collections.Generic
Using System.Data
Using System.Data.Sqlite
Using System.Threading.Tasks

Class App
  
  Async Static Method GetResultsAsync(sql As String, FieldName As String) As Task<List<String>>
     var cnStr := "Data Source=BookLib.db3"
     var results := List<String>{}
     Begin using var cn := SqliteConnection{cnStr}
       cn:Open()
       var cmd := cn:CreateCommand()
       cmd:CommandText := sql
       ? "Async query started..."
       Begin Using var reader := await cmd:ExecuteReaderAsync()
           While await reader:ReadAsync()
             results:Add(reader[fieldName]:ToString())
           End While
       End Using
     End Using
     ? "Async query ended..."
     // Artifical delay
     await Task.Delay(1000)
     Return results

  Static Async Method InvokeQueryAsync() As Task<List<String>>
    var sqlCmd := "Select * From Book"
    var field := "title"
    var results := await GetResultsAsync(sqlCmd, field)
    ? "Do some other work"
    return results
  
  Static Async Method StartAsync() As Task
    // since the Start method cannot be async...
    var results := await InvokeQueryAsync()
    ForEach var title in results
      ? title
    Next

  Static Method Start() As Void
    var t := Task.Run({=> StartAsync()})
    t:Wait()
    
End Class