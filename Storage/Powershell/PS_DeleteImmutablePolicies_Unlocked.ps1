##The below script helps in deleting Immutable policies(unlocked) from Blobs using ps to invoke Delete Blob Immutability Policy REST API. Script will use the SAS token signed by the storage account key.. 
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

   $storageAccountName = "<--Your storage account name-->"

   $containerName = "<--Your storage account name-->"

   $storage_shared_key = "<--storage account access key-->"

   $CurrentTime = Get-Date 

   $StartTime = $CurrentTime.AddHours(-1.0)

   $EndTime = $CurrentTime.AddHours(11.0) 

   $SASPermissions = 'racwdi'

   $context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storage_shared_key
   # Using Storage account key to generate a new SAS token ###

   $sas = New-AzStorageContainerSASToken -Name $containerName -Permission $SASPermissions -StartTime $StartTime -ExpiryTime $EndTime -Context $context

   $sas = $sas.Replace("?","")
 
        $blobs = Get-AzStorageBlob -Container $containerName -Context $context
 
         foreach($blob in $blobs)
        {
                $uri = "https://" + $blob.BlobClient.Uri.Host + $blob.BlobClient.Uri.AbsolutePath + "?comp=immutabilityPolicies&" + $sas
                #confirm URI looks ok 
                  Write-Output "URI:"$uri
                try{
                  $res = Invoke-RestMethod -Method "delete" -Uri $uri
                  Write-Output "Removed immutability policy from blob:" $blob.Name
                } catch {
            Write-Warning "Error removing immutability policy from blob: $($blob.Name) - $($_.Exception.Message)"
        }
      }
