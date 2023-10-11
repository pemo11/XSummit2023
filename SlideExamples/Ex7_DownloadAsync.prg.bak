// file: Ex7_DownloadAsync.prg
// taken from the X# help file and slightly modified;)

USING System
USING SYSTEM.IO
USING System.Net
USING System.Threading.Tasks
 
FUNCTION Start() AS VOID
    ? "1. calling long process"
    App.StartDownload()
    ? "2. this should be printed while processing"
    Console.ReadKey()
 
CLASS App
  STATIC PROTECT oLock AS OBJECT     // To make sure we synchronize the writing to the screen
  STATIC downloadUrl := "http://www.xsharp.info/index.php" As String

  STATIC CONSTRUCTOR
    oLock := OBJECT{}
    ServicePointManager.SecurityProtocol := SecurityProtocolType.Tls12
 
  ASYNC STATIC METHOD StartDownload() As Void
    var Size := Await DownloadFile()
    ? "3. returned from long process"
    ? Size, " Bytes downloaded"
 
  ASYNC STATIC METHOD DownloadFile() As Task<Int64>
    VAR WebClient := WebClient{}
    VAR FileName := Path.GetTempPath() +"temp.txt"
    webClient:DownloadProgressChanged += OnDownloadProgress
    webClient:Credentials := CredentialCache.DefaultNetworkCredentials
    Await webClient:DownloadFileTaskAsync(downloadUrl, FileName)
    VAR filePath := Path.Combine(Path.GetTempPath(), "temp.txt")
    IF file:Exists(filePath)
      VAR size := FileInfo{filePath}:Length
      File.Delete(filePath)
      RETURN size
    ENDIF
    RETURN 0
 
   STATIC METHOD OnDownloadProgress(sender AS OBJECT, e AS System.Net.DownloadProgressChangedEventArgs) AS VOID
     BEGIN LOCK oLock
         ? String.Format("{0,3} % Size: {1,8:N0} Thread {2}", 100*e:BytesReceived / e:TotalBytesToReceive , e:BytesReceived, ;
           System.Threading.Thread.CurrentThread:ManagedThreadId)
     END LOCK
     RETURN
 
END CLASS 