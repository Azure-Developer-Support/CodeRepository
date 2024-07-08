#The below PowerShell script helps you to add blob index tags to blobs with REST API using SAS Token

#By using the following materials or sample code you agree to be bound by the license terms below and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you are located, one of its affiliates) and you. Any materials (other than this sample code) we provide to you are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to use and modify the sample code and to reproduce and distribute the object code form of the sample code, provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the sample code." 

$storageAccountURI = "https://<StorageAccountName>.blob.core.windows.net/"
$containerName = "<ContainerName>"
$blobName = "<BlobName>"
$SASToken = "<SASToken>"

$URI = $storageAccountURI + $containerName + "/" + $blobName +  "?comp=tags&" + $SASToken 

#Add the blob tags
$Body =@"
   <?xml version="1.0" encoding="utf-8"?>
<Tags>  
    <TagSet>  
        <Tag>  
            <Key>Tag Name</Key>  
            <Value>Tag Value</Value>  
        </Tag>  
    </TagSet>  
</Tags>
"@

$headers = @{
    'x-ms-date' = 'Date In UTC'
    'x-ms-version' = 'Storage service version' #for e.g.- 2024-08-04
    'Content-Length' = 'Content Lenght'  #for e.g.- 207
    'Content-Type' = 'application/xml;charset=UTF-8'
}

#Invocation of the API
Invoke-RestMethod -Uri $uri -Method PUT -Headers $headers -Body $body
