# The below PowerShell script helps to copy all the Archived blobs from a Source Container and rehydrates it to an online tier by copying the blob to a Destination Container on different Storage account.

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

################# Script BEGIN ####################  

# Storage account details

Connect-AzAccount
$rgName = "ResourceGroupName"
$srcAccountName = "Your SourceStorageAccountName"
$srcContainerName = "Your SourceContainerName"
$destAccountName = "Your DestinationStorageAccountName"
$destContainerName = "Your DestinationContainerName"



$srcStorageAccount = Get-AzStorageAccount -ResourceGroupName $rgName -AccountName $srcAccountName
$srcContext = $srcStorageAccount.Context



$destStorageAccount = Get-AzStorageAccount -ResourceGroupName $rgName -AccountName $destAccountName
$destContext = $destStorageAccount.Context



$MaxReturn = 5000



$blob_continuation_token = $null
             
  do
    {



     $sourceBlobs = Get-AzStorageBlob -Context $srcContext -Container $srcContainerName -MaxCount $MaxReturn -ContinuationToken $blob_continuation_token | Where-Object{$_.ICloudBlob.Properties.StandardBlobTier -eq "Archive"}



     foreach ($blob in $sourceBlobs) {
      
        $sas = New-AzStorageBlobSASToken -Container $srcContainerName -Permission "r" -Context $srcContext -Blob $blob.Name
        $sasToken = $blob.ICloudBlob.Uri.AbsoluteUri + $sas
        Start-AzStorageBlobCopy -AbsoluteUri $sasToken -DestBlob $blob.Name -DestContext $destContext -DestContainer $destContainerName -RehydratePriority High -StandardBlobTier Cool
       
       }
      if ($sourceBlobs -ne $null)
        {
          $blob_continuation_token = $sourceBlobs[$sourceBlobs.Count - 1].ContinuationToken
                                       
        }



     if ($blob_continuation_token -ne $null)
        {
         Write-Verbose ("Blob listing continuation token = {0}" -f $blob_continuation_token.NextMarker)
        }



   } while ($blob_continuation_token -ne $null)


################# Script END #################### 
