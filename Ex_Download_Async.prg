ls// file: Ex_Download_Async.prg
// Downloading web content asynchronously (good)
// Compile with /main:App /r:System.Net.Http.dll

using System
using System.Net
using System.Net.Http
using System.Threading.Tasks

Class App

    Static Async Method DownloadDocsMainPageAsync() As Task<int> 
        Console.WriteLine(i"{nameof(DownloadDocsMainPageAsync)}: About to start downloading.")
        var client := HttpClient{}
        var url := "https://learn.microsoft.com/en-us/"
        Local content := await client:GetByteArrayAsync(url) As Byte[]
        Console.WriteLine(i"{nameof(DownloadDocsMainPageAsync)}: Finished downloading.")
        Return content:Length

    Static Async Method StartDownload() As Task
       Local downloadTask := DownloadDocsMainPageAsync() As Task<Int>
       Console.WriteLine(i"{nameof(StartDownload)}: Launched downloading.")
       var bytesLoaded := await downloadTask
       Console.WriteLine(i"{nameof(StartDownload)}: Downloaded {bytesLoaded} bytes.")
    
    Static Method Start() As Void
        ServicePointManager.SecurityProtocol := SecurityProtocolType.Tls12
        var t := Task.Run({ => StartDownload() })
        t:Wait()
          
End Class

