using Azure.Storage.Blobs.Specialized;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;

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
