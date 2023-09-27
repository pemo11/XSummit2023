// file: Ex_ExecuteReaderAsyncWrong.prg
// Example for an asynchronous database query
// compile with /main:App /r:System.Data.Sqlite.dll

Using System.Collections.Generic
Using System.Data
Using System.Data.Sqlite
Using System.Threading.Tasks

Class App
  
  Async Static Method InvokeQuery(sql As String, FieldName As String) As Task<List<String>>
     var cnStr := "Data Source=BookLib.db3"
     var results := List<String>{}
     Begin using var cn := SqliteConnection{cnStr}
       // Don't forget to open the connection...
       cn:Open()
       var cmd := cn:CreateCommand()
       cmd:CommandText := sql
       // As Task<SqliteDataReader> 
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

  Async Static Method InvokeQueryAsync() As Void
    var sqlCmd := "Select * From Book"
    var field := "title"
    var results := await InvokeQuery(sqlCmd, field)
    ? i"{results.Count} books queried..."
    ForEach var title in results
      ? title
    Next
    
  Static Method Start() As Void
    // Wrong because programm does not wait
    //  InvokeQueryAsync() 
    var t := Task.Run({ => InvokeQueryAsync()})
    t:Wait()
    // the only chance to see the results
    // Console.ReadLine()    
End Class