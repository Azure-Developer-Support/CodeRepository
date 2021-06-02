#The below PowerShell script helps you to download the blob using Secondary Endpoint in RAGRS Storage account
#The script can be modified based on the requirements.

#Disclaimer

#By using the following materials or sample code you agree to be bound by the license terms below 
#and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
#are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
#are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
#use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
#provided that you agree: (i) to not use Microsoftâ€™s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
#which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
#a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
#suppliers from and against any third party claims or lawsuits, including attorneysâ€™ fees, that arise or result 
#from the use or distribution of the sample code."


#We first need to get the endpoint and append the BlobEndpoint section pointing to secondary endpoint at the end of the connection string like the one given below:
#DefaultEndpointsProtocol=https;AccountName=<StorageAccountName>;AccountKey=35tCZY3DXXXXXXXXXXXXXXXXXXXXXXXXXX==;EndpointSuffix=core.windows.net;BlobEndpoint=https://<StorageAccountName>-secondary.blob.core.windows.net


$bMaxReturn = 100   

$connectionString = "DefaultEndpointsProtocol=https;AccountName=<StorageAccountName>;AccountKey=35tCZY3DXXXXXXXXXXXXXXXXXXXXXXXXXX==;EndpointSuffix=core.windows.net;BlobEndpoint=https://<StorageAccountName>-secondary.blob.core.windows.net"

$storageContext = New-AzStorageContext -ConnectionString $connectionstring

$containerName = "Storage Container Name"

Write-Host "Listing Blobs for Container : " $containerName
do   

{   
    # get a list of all of the blobs in the container    

    $listOfBlobs = Get-AzStorageBlob -Container $containerName -Context $storageContext -MaxCount $bMaxReturn -ContinuationToken $bToken    

                 if($listOfBlobs.Length -le 0) { Break;}   

          foreach($blob in $listOfBlobs) {   

               write-host "Blob name:" 

               write-host $blob.Name 

               } 

                    $bToken = $blob[$blob.Count -1].ContinuationToken; 

}while ($bToken -ne $Null)     