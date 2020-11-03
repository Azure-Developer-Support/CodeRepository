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
// System.Configuration.ConfigurationManager

// This class file contains .Net Core 3.1 sample code to upload data as mutiple blocks to form one blob on storage account

using Azure.Storage.Blobs.Specialized;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;

namespace StorageSamples.BlobSamples
{
    class UploadBlockBlob
    {
        public void Upload(string filePath)
        {
            // Set the max block size in bytes. There are a few supported block sizes 64kb, 128kb, 256kb, 512kb, 1Mb, 2Mb, 4Mb, 100Mb
            // Smaller block size will result in faster processing of write request, but will increase total no. of write operations
            int MAX_BLOCK_SIZE = 512000; // 512kb

            // Get the connection string to storage account
            string connectionString = ConfigurationManager.ConnectionStrings["StorageConnectionString"].ConnectionString;

            // Set the container name
            string containerName = "testcontainer";

            // Set the complete block blob path and name. You can also use just the name if you want to upload to root
            string blobName = "testblockBlob.txt";

            // We are using the Blobs.Specialized.BlockBlobClient to quickly create block blob object with minimal code
            BlockBlobClient blob = new BlockBlobClient(connectionString, containerName, blobName);

            // Maintain a list of block Ids to commit
            List<string> blockIds = new List<string>();

            // variable to compute block id
            int blockId = 0;

            // variable to maintain blocks/content processed
            int contentProcessed = 0;

            // Get the file/data contents in bytes
            byte[] fileContents = File.ReadAllBytes(filePath);

            // Set current block size to MAX size
            int currentBlockSize = MAX_BLOCK_SIZE;

            while (currentBlockSize == MAX_BLOCK_SIZE)
            {
                // If content processed + current block size exceeds file length, 
                // then set current block size to difference of file length - content processed
                // this is done to capture the last block that is smaller than MAX block size
                if ((contentProcessed + currentBlockSize) > fileContents.Length)
                    currentBlockSize = fileContents.Length - contentProcessed;

                // Create an array consisting only the subset/block of the file content
                byte[] byteBlock = new byte[currentBlockSize];
                Array.Copy(fileContents, contentProcessed, byteBlock, 0, currentBlockSize);

                // Create a Base64 string for block ID. We can use any Base64 string, but be sure to hold the value to commit
                string blockID = Convert.ToBase64String(System.BitConverter.GetBytes(blockId));

                // We are staging/adding a new block to a blob in storage account, to be committed later
                blob.StageBlock(blockID, new MemoryStream(byteBlock, true));

                // Adding block IDs to list
                blockIds.Add(blockID);

                // Increase total blocks created
                contentProcessed += currentBlockSize;
                blockId++;
            }

            // Commit all the blocks to storage account. Unless committed, we will not see the file in storage account
            blob.CommitBlockList(blockIds);
        }
    }
}
