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

// Dependencies: Following nuget packages needs to be installed
// Azure.Storage.Blobs
// Newtonsoft.Json, if you need to serialize & deserialze objects
// System.Configuration.ConfigurationManager

// This class file contains .Net Core 3.1 sample code to upload data as stream to a block blob
// and download block blob content to a memory stream

using Azure.Storage.Blobs.Specialized;
using System;
using System.Configuration;
using System.IO;
using System.Text;

namespace StorageSamples.BlobSamples
{
    class UploadDownloadBlockBlobUsingStream
    {
        public void UploadBlockBlobStream()
        {
            // Get the connection string to storage account
            string connectionString = ConfigurationManager.ConnectionStrings["StorageConnectionString"].ConnectionString;

            // Set the container name
            string containerName = "testcontainer";

            // Set the complete block blob path and name. You can also use just the name if you want to upload to root
            string blobName = "parentDirectory/childDirectory/testBlockBlob.txt";

            // Content we want to upload. We can also serialze an object to JSON here
            // var obj = new MyObject { ID = 1, Name = "BlockBlob", SomeDate = DateTime.UtcNow };
            // var content = Newtonsoft.Json.JsonConvert.SerializeObject(obj);
            var content = "This content will be written to a block blob in storage account";

            // Convert our contet to byte data
            var bytesData = Encoding.UTF8.GetBytes(content);

            // We are using the Blobs.Specialized.BlockBlobClient to quickly create block blob object with minimal code
            BlockBlobClient blob = new BlockBlobClient(connectionString, containerName, blobName);

            // Using memory stream to upload data
            using (var memoryStream = new MemoryStream(bytesData))
            {
                blob.Upload(memoryStream);
            }
        }

        public void DownloadBlockBlobStream()
        {
            // Get the connection string to storage account
            string connectionString = ConfigurationManager.ConnectionStrings["StorageConnectionString"].ConnectionString;

            // Set the container name
            string containerName = "testcontainer";

            // Set the complete block blob path and name. You can also use just the name if you want to download from root
            string blobName = "parentDirectory/childDirectory/testBlockBlob.txt";

            // We are using the Blobs.Specialized.BlockBlobClient to quickly create block blob object with minimal code
            BlockBlobClient blob = new BlockBlobClient(connectionString, containerName, blobName);

            using (var memoryStream = new MemoryStream())
            {
                // Downloading block blob content to MemoryStream
                blob.DownloadTo(memoryStream);

                // Reading contents from memory stream
                var content = Encoding.UTF8.GetString(memoryStream.ToArray());

                // We can also Deserialize the content to an object
                // var obj = Newtonsoft.Json.JsonConvert.DeserializeObject<MyObject>(content);
                // Console.WriteLine($"ID: '{obj.ID}', Name: '{obj.Name}', SomeDate: '{obj.SomeDate}'");
                Console.WriteLine(content);
            }
        }
    }

    class MyObject
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public DateTime SomeDate { get; set; }
    }
}
