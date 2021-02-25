# The below PowerShell script helps you to copy the blobs that are present in all the containers of a storage account to another container present in the same storage account. 
#The script can be modified based on the requirements.
# Note : The variable $destcontainer is used in if loop to make sure that there are no duplicate copy operation as foreach loop to retrieve all the containers will fetch the container where you copy the blobs as well.

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

Connect-AzAccount
$storageAccountName = "your storage account name"
$resourceGroupName = "your resource group name"
$destcontainer = "destination container to copy blobs"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName 
$ctx = $storageAccount.Context

$MaxReturn = 5000

$container_continuation_token = $null

do {

    $containers = Get-AzStorageContainer -Context $ctx -MaxCount $MaxReturn -ContinuationToken $container_continuation_token

    $container_continuation_token = $null;

 
        if ($containers -ne $null)
            {
                $container_continuation_token = $containers[$containers.Count - 1].ContinuationToken
                foreach($containerctx in $containers)
                    {
                        $container = $containerctx.Name

                        Write-Verbose "Processing container : $container"
                        $blob_continuation_token = $null
                
                        do 
                            {

                                if ($container -ne $destcontainer)

                                    {
                                        $blobs = Get-AzStorageBlob -Context $ctx -Container $container -MaxCount $MaxReturn -ContinuationToken $blob_continuation_token 
                                        $blobs | Start-AzStorageBlobCopy -DestContainer $destcontainer
                                    }

                                if ($blobs -ne $null)
                                    {
                                        $blob_continuation_token = $blobs[$blobs.Count - 1].ContinuationToken
                                       
                                    }


                                if ($blob_continuation_token -ne $null)
                                    {
                                        Write-Verbose ("Blob listing continuation token = {0}" -f $blob_continuation_token.NextMarker)
                                    }

                              } while ($blob_continuation_token -ne $null)

                        Write-Verbose "Finished processing Container $container"
                        
                    }

            }
         If ($container_continuation_token -ne $null)
            {
                Write-Verbose ("Container listing continuation token = {0}" -f $container_continuation_token.NextMarker)
            }

    } while ($container_continuation_token -ne $null)
