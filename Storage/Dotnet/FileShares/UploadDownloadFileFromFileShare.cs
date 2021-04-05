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
// Azure.Storage.Files.Shares
// System.Configuration.ConfigurationManager

// This class file contains .Net Core 3.1 sample code to connect to a File Share using Access Key,
// upload file and download a file.

using Azure;
using Azure.Storage.Files.Shares;
using Azure.Storage.Files.Shares.Models;
using System.Configuration;
using System.IO;

namespace FileShareSamples
{
    class UploadDownloadFileFromFileShare
    {
        const string shareName = "testfileshare";

        const string directoryName = "testdirectory";

        const string fileName = "testfile.txt";

        public void UploadFile(string localFilePath)
        {
            // Create a client to a file share
            ShareClient share = new ShareClient(ConfigurationManager.ConnectionStrings["StorageConnectionString"].ConnectionString, shareName);

            // Get a directory client on file share and create directory if not exists
            ShareDirectoryClient directory = share.GetDirectoryClient(directoryName);
            directory.CreateIfNotExists();

            // Get a reference to a file and upload it
            ShareFileClient file = directory.GetFileClient(fileName);

            using (FileStream stream = File.OpenRead(localFilePath))
            {
                file.Create(stream.Length);
                file.UploadRange(
                    new HttpRange(0, stream.Length),
                    stream);
            }
        }

        public void DownloadFile(string localFilePath)
        {
            // Create a client to a file share
            ShareClient share = new ShareClient(ConfigurationManager.ConnectionStrings["StorageConnectionString"].ConnectionString, shareName);

            // Get a directory client on file share
            ShareDirectoryClient directory = share.GetDirectoryClient(directoryName);

            // Get a reference to a file and upload it
            ShareFileClient file = directory.GetFileClient(fileName);

            // Download the file
            ShareFileDownloadInfo download = file.Download();

            using (FileStream stream = File.OpenWrite(localFilePath))
            {
                download.Content.CopyTo(stream);
            }
        }
    }
}
