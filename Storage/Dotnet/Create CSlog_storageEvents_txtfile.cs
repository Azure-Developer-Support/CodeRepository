/DISCLAIMER

//The sample scripts are not supported under any Microsoft standard support program or service.
//The sample scripts are provided AS IS without warranty of any kind.Microsoft further disclaims all implied warranties including, without limitation, 
//any implied warranties of merchantability or of fitness for a particular purpose.The entire risk arising out of the use or performance of the sample 
//scripts and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of 
//the scripts be liable for any damages whatsoever (including without limitation, damages for loss of business profits, business interruption, loss of business 
//information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of
//the possibility of such damages.
public class TestWorm
{
    static string username = "Storage account";
    static string pwd = "storage account key ";
    string ConnectionString = string.Format(CultureInfo.InvariantCulture, "DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1};EndpointSuffix=core.windows.net", username, pwd);
    StreamWriter file = new StreamWriter(@"c:\\azureevents.txt", append: true);
    public void TestAzureevtApp()
    {

        AzureEventSourceListener listener = new AzureEventSourceListener((e, message) =>
                {
                      
                    file.WriteLine("Sample message");
                    file.WriteLine($"{DateTime.Now} {message}");
                    Console.WriteLine($"{DateTime.Now} {message}");
                },                    
                level: System.Diagnostics.Tracing.EventLevel.LogAlways
            );

        string connectionString = ConnectionString;
        string containerName = "XXX";
        BlobContainerClient container = new BlobContainerClient(connectionString, containerName);
        BlobContainerProperties bcp = container.GetProperties();
        BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);                   

        bool? hasimmpolicy = bcp.HasImmutabilityPolicy;
        bool? hasimmstoragewithversioning = bcp.HasImmutableStorageWithVersioning;
        bool? haslegalhold = bcp.HasLegalHold;

        file.Close();
        Console.ReadLine();
    }

}
