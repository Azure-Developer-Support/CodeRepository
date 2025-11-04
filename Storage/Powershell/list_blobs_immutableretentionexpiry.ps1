
# Note: If we have immuatble policy with Timebased retention the blobs has to be in conatiner til lthe retentione xexpires and then only we can delete the blobs 
#This script helps to List all the blobs with version along with Immutable retention expiry days

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

# Connect using Azure AD (interactive login)
Connect-AzAccount
 
# Set the subscription context
Set-AzContext -Subscription "subID"
 
# Define parameters
$resourceGroup = "RG name"
$storageAccountName = "SA name"
$containerName = "Container name "
 
# Get storage account and context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName
$context = $storageAccount.Context
 
# Get blob versions
$blobVersions = Get-AzStorageBlob -Container $containerName -Context $context -IncludeVersion
 
# Loop through each blob version and display retention info
foreach ($blob in $blobVersions) {
    $properties = $blob.BlobClient.GetProperties()
    $immutability = $properties.Value.ImmutabilityPolicy
 
    Write-Host "Blob Name: $($blob.Name)"
    Write-Host "Retention Expiry: $($immutability.ExpiresOn)"
    Write-Host "-----------------------------"
}

