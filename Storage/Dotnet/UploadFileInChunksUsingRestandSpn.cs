//'By using the following materials or sample code you agree to be bound by the license terms below 
//'and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
//'These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
//'are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
//'are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
//'not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
//'use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
//'provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
//'in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
//'which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
//'a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
//'limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
//'suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result 
//'from the use or distribution of the sample code."  

// This class file contains .Net sample code to upload files in chunks of 2 mb to a block blob to ADLS Gen 2 account

using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Auth;
using Microsoft.WindowsAzure.Storage.Blob;
using Newtonsoft.Json;
using System;
using System.Globalization;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading;

namespace AdlsGen2FileOps
{
    class Program
    {
        static void Main(string[] args)
        {
            const string ResourceId = "https://somaadlsgen2.blob.core.windows.net/"; 
            const string AuthInstance = "https://login.microsoftonline.com/{0}/";
            string authority = string.Format(CultureInfo.InvariantCulture, AuthInstance, "Your Tenant Id");
            AuthenticationContext authContext = new AuthenticationContext(authority);
            var clientCred = new ClientCredential("Client ID", "Client Secret");
            AuthenticationResult result = authContext.AcquireTokenAsync(ResourceId, clientCred).Result;

            var _tokenCredentials = new TokenCredential(result.AccessToken);

            //REST API
            var URI = new Uri("https://somaadlsgen2.dfs.core.windows.net/shell01/PROJECT/abc2.pdf?resource=file"); // Storage account details

            var date = DateTime.Now.ToString("R");

            HttpClient client = new HttpClient();
            client.DefaultRequestHeaders.Add("authorization", "Bearer " + result.AccessToken);
            client.DefaultRequestHeaders.Add("x-ms-date", date);
            client.DefaultRequestHeaders.Add("x-ms-version", "2018-11-09");
            var jsonContent = new StringContent(string.Empty);
            var a = client.PutAsync(URI, jsonContent).Result;

            var stream = new FileStream(@"C:\Users\suchak\Desktop\superprof\file.txt", FileMode.Open, FileAccess.Read);
            var date1 = DateTime.Now.ToString("R");

            // Uploading file in chunks
            int chunckSize = 2097152; //2MB
            var file1 = new FileStream(@"C:\Users\Desktop\abcfolder\sample-pdf-download-10-mb.pdf", FileMode.Open, FileAccess.Read); // Local File Path that you want to upload
            int totalChunks = (int)(file1.Length / chunckSize);
            if (file1.Length % chunckSize != 0)
            {
                totalChunks++;
            }

            for (int i = 0; i < totalChunks; i++)
            {
                long position = (i * (long)chunckSize);
                int toRead = (int)Math.Min(file1.Length - position, chunckSize);
                byte[] buffer = new byte[toRead];
                file1.ReadAsync(buffer, 0, buffer.Length);

                var newUri = new Uri("https://somaadlsgen2.dfs.core.windows.net/shell01/PROJECT/abc2.pdf");
                var resourceUrl = $"{newUri}?action=append&timeout={5000}&position={position}";
                var msg = new HttpRequestMessage(new HttpMethod("PATCH"), resourceUrl);
                msg.Headers.Add("x-ms-lease-action", "acquire");
                msg.Headers.Add("authorization", "Bearer " + result.AccessToken);
                msg.Headers.Add("x-ms-date", date1);
                msg.Headers.Add("x-ms-version", "2018-11-09");
                msg.Content = new StreamContent(new MemoryStream(buffer));

                var r = client.SendAsync(msg).Result;
            }

            var newUri1 = new Uri("https://somaadlsgen2.dfs.core.windows.net/shell01/PROJECT/abc2.pdf");
            var flushUrl = $"{newUri1}?action=flush&timeout={5000}&position={file1.Length}";
            var flushMsg = new HttpRequestMessage(new HttpMethod("PATCH"), flushUrl);
            flushMsg.Headers.Add("x-ms-lease-action", "acquire");
            flushMsg.Headers.Add("authorization", "Bearer " + result.AccessToken);
            flushMsg.Headers.Add("x-ms-date", date1);
            flushMsg.Headers.Add("x-ms-version", "2018-11-09");
            var r1 = client.SendAsync(flushMsg).Result;

            Console.WriteLine("File Uploaded Successfully !!");
      }
}
