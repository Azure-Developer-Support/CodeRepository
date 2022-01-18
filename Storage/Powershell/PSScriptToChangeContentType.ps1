﻿#The below PowerShell script helps to traverse through the blobs of a particular container.
#It will try matching the condition for source content type and convert the target content type.

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

#Connect-AzAccount
$bMaxReturn = 100   

$ConnectionString = "STORAGE ACCOUNT CONNECTION STRING"

$StorageContext = New-AzStorageContext -ConnectionString $connectionstring

$ContainerName = "NAME OF THE STORAGE CONTAINER"

$SourceContentType =  "SOURCE CONTENT TYPE"

$TargetContentType = "DESTINATION CONTENT TYPE"

do   

{   
    # get a list of all of the blobs in the container    

    $listOfBlobs = Get-AzStorageBlob -Container $containerName -Context $storageContext -MaxCount $bMaxReturn -ContinuationToken $bToken    

                 if($listOfBlobs.Length -le 0) { Break;}   

          foreach($blob in $listOfBlobs) { 
              
                    if ($blob.ContentType -eq $SourceContentType)
                    {
                        $blob.ICloudBlob.Properties.ContentType = $TargetContentType
                        $blob.ICloudBlob.SetProperties();
                        write-host "Content Type changed for blob : " $blob.Name
        
                     }
                   } 

                    $bToken = $blob[$blob.Count -1].ContinuationToken; 

}while ($bToken -ne $Null)   
