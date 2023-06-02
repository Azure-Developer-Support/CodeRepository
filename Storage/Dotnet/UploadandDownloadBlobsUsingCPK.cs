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

//Dependencies : Below nuget packages needs to be installed.
Microsoft.Azure.Storage;

//Please make sure you define connection string in App.config file as we are referring it from AppSettings in the below code.

using System;
using System.Text;
using Microsoft.Azure.Storage;
using Microsoft.Azure.Storage.Blob;
using System.Security.Cryptography;
using System.Configuration;
using System.IO;

namespace CustomerProvidedKeys
{
    class Program
    {
        static void Main(string[] args)
        {
            AesCryptoServiceProvider keyAes = new AesCryptoServiceProvider();

            BlobCustomerProvidedKey customerProvidedKey = new BlobCustomerProvidedKey(keyAes.Key);

            var requestOptions = new BlobRequestOptions
            {
                CustomerProvidedKey = customerProvidedKey
            };
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings.Get("StorageConnectionString"));
            CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();
            string blobName = CPK.UploadBlobsWithCPK(requestOptions, blobClient);
            CPK.DownloadBlobsWithCPK(requestOptions, blobClient, blobName);
        }
    }
    public static class CPK
    {
        /// <summary>
        /// Method that uploads blobs with Customer Provided Keys
        /// </summary>
        /// <param name="requestOptions"></param>
        /// <param name="blobClient"></param>
        /// <returns></returns>
        public static string UploadBlobsWithCPK(BlobRequestOptions requestOptions, CloudBlobClient blobClient)
        {
           
            CloudBlobContainer container = blobClient.GetContainerReference("your container name");
            string blobName = "cpk-blob" + Guid.NewGuid() + ".txt";
            var blockBlob = container.GetBlockBlobReference(blobName);
            
            string sourceFile = @"file path from local to upload the file";
            var content = File.ReadAllText(sourceFile);
            var bytesData = Encoding.UTF8.GetBytes(content);
            using (var memoryStream = new MemoryStream(bytesData))
            {
                blockBlob.UploadFromStream(memoryStream, null, requestOptions, null);
            }
            return blobName;
        }

        /// <summary>
        /// Method that downloads using Customer provided keys
        /// </summary>
        /// <param name="requestOptions"></param>
        /// <param name="blobClient"></param>
        /// <param name="blobName"></param>
        public static void DownloadBlobsWithCPK(BlobRequestOptions requestOptions, CloudBlobClient blobClient, string blobName)
        {
            CloudBlobContainer container = blobClient.GetContainerReference("test");
            CloudBlockBlob blob = container.GetBlockBlobReference(blobName);
            string _destPath = @"folder or directory path from local where you want to download the blob" + blob.Name.ToString();

            MemoryStream mem = new MemoryStream();
            blob.DownloadToStream(mem, null, requestOptions, null);
            FileStream file = new FileStream(_destPath, FileMode.Create, FileAccess.Write);
            mem.WriteTo(file);
            file.Close();
            mem.Close();

        }
    }
}
