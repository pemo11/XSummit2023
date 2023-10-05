// file: Ex_Download_Sync.prg
// Downloading web content synchronously like in the past (not good)
// compile with /main:App 

using System
using System.Net

Class App

    Static Method DownloadDocsMainPage() As Int 
        Console.WriteLine(i"{nameof(DownloadDocsMainPage)}: About to start downloading.")
        var client := WebClient{}
        var url := "https://learn.microsoft.com/en-us/"
        Local content := client:DownloadData(url) As Byte[]
        Console.WriteLine(i"{nameof(DownloadDocsMainPage)}: Finished downloading.")
        Return content:Length

    Static Method Start() As Void
       ServicePointManager.SecurityProtocol := SecurityProtocolType.Tls12
       Console.WriteLine(i"{nameof(Start)}: Launched downloading.")
       Local bytesLoaded := DownloadDocsMainPage() As Int
       Console.WriteLine(i"{nameof(Start)}: Downloaded {bytesLoaded} bytes.")
          
End Class

