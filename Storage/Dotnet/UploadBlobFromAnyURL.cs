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

//Pre-requisite: Following nuget packages needs to be installed
//Azure.Storage.Blobs
//Azure.Storage.Common

//This code will help uplaoding a file from internet to blob using memory stream 

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Azure.Storage.Blobs;

namespace UploadBlobFromURL
{
    class Program
    {
        static void Main(string[] args)
        {


            //Storage connection string            
            
            string connectionString = "DefaultEndpointsProtocol=https;AccountName=XXXX;AccountKey=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;EndpointSuffix=core.windows.net";
            //Container Name
            string containerName = "test";

            //The name of the file on storage
            string ImageName = "NewImage3.gif";

            //Public URL which you want to upload it to storage account. update it to a correct URL
            string file = "https://support.content.office.net/en-us/media/msn_video_widget.gif";

            //Get the container reference
            BlobContainerClient container = new BlobContainerClient(connectionString, containerName);

            //create web client to download the content of the public file
            WebClient wc = new WebClient();

            //Download the memory stream of the file
            MemoryStream stream = new MemoryStream(wc.DownloadData(file));

            //create the file in storage account with specified name
            BlobClient cblob = container.GetBlobClient(ImageName);

            //Upload the blobs synchronously, you can update asynchronously if required
            cblob.Upload(stream);


        }
    }
}
