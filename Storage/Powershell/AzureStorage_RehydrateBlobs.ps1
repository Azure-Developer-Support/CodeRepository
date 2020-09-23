
###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########These scripts provide details on rehydrating blobs of a storage account for few common scenarios#########################
#Ref links:https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-rehydration?tabs=azure-portal, https://docs.microsoft.com/en-us/powershell/module/az.storage/get-azstorageblob?view=azps-4.7.0

############################Script Sample 1#######################################

#This will help in rehydrating all blobs of a specific containers to Hot or cool tier
#
#Please update these value as per your scenario

$StorageAccountName = "<your storage account name>"
$ResourceGroup = "<your storage account resource group>"
$ContainerName = "<your container name>" 

#you can uncomment this login command if you're already logged in
Login-AzAccount

$sa = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroup

#get all of your archived blobs under a container as mentioned below

$blobs = Get-AzStorageBlob -Container $ContainerName -Context $sa.Context | Where-Object{$_.ICloudBlob.Properties.StandardBlobTier -eq "Archive"}

#loop through each blob and set the blob tier to hot or cool

foreach($blob in $blobs){

    #You can use Hot instead of cool if you wish to move the blobs to Hot tier
    $blob.ICloudBlob.SetStandardBlobTier("Cool"); 
}

Echo("Total " + $blobs.Count + " blobs are being rehydrated.")

############################Script sample 2#######################################
#This will help in rehydrating all blobs of a particular folder/subdirectory not all blobs of a container

#Please update these value as per your scenario
$StorageAccountName = "<your storage account name>"
$ResourceGroup = "<your storage account resource group>"
$ContainerName = "<your container name>"
$FolderPath = "<your folder/subdirectory name excluding container name>" 

#you can uncomment this login command if you're already logged in
Login-AzAccount

$sa = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroup

#get all of your archived blobs inside a folder and its subfolder.
#-Prefix specifies a prefix for the blob names that you want to get. 
#-Prefix does not support using any regular expressions or wildcard characters to filter. 

$blobs = Get-AzStorageBlob -Prefix $FolderPath -Container $ContainerName -Context $sa.Context | Where-Object{$_.ICloudBlob.Properties.StandardBlobTier -eq "Archive"}

foreach($blob in $blobs){
    
    #You can use Hot instead of cool if you wish to move the blobs to Hot tier
    $blob.ICloudBlob.SetStandardBlobTier("Cool"); 
}

Echo("Total " + $blobs.Count + " blobs are being rehydrated.")

############################Script sample 3#######################################
#This script is not for rehydrating but to help in validating the list of files we're going to rehydrate with our filters on Get-AzStorageBlob
#You can basically export the output of Get-AzStorageBlob to csv files like below and can inspect if it's selecting the expected list of files or not.

#Please update these value as per your scenario
$StorageAccountName = "<your storage account name>"
$ResourceGroup = "<your storage account resource group>"
$ContainerName = "<your container name>"
$FolderPath = "<your folder/subdirectory name excluding container name>" 
$LocalPathtoExport ="<Local path to store the .csv files>"
#$LocalPathtoExport ="c:\Braja\so.csv"

#you can uncomment this login command if you're already logged in
Login-AzAccount

$sa = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroup
$blobs = Get-AzStorageBlob -Prefix $FolderPath -Container $ContainerName -Context $sa.Context | Where-Object{$_.ICloudBlob.Properties.StandardBlobTier -eq "Archive"} | export-csv -Path $LocalPathtoExport -NoTypeInformation


############################Script sample 3#######################################
#This will help in rehydrating all blobs of a particular folder/subdirectory with continuation token. This is useful in cases where you expect huge numbers of blobs for rehydration
#You can rehydrate them in batches using MaxCount and ContinuationToken parameter as below

#you can update this value as per your scenario
$MaxReturn = 10000
$Total = 0
$Token = $Null
$StorageAccountName = "<your storage account name>"
$ResourceGroup = "<your storage account resource group>"
$ContainerName = "<your container name>" 
$FolderPath = "<your folder/subdirectory name excluding container name>"

Login-AzAccount
$sa = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroup

do
 {
      
     $blobs = Get-AzStorageBlob -Prefix $FolderPath -Container $ContainerName -Context $sa.Context -MaxCount $MaxReturn -ContinuationToken $Token | Where-Object{$_.ICloudBlob.Properties.StandardBlobTier -eq "Archive"}

     $Total += $blobs.Count;
     if($blobs.Length -le 0) { Break;}

     $Token = $blobs[$blobs.Count -1].ContinuationToken;
     foreach($blob in $blobs){
    
        #You can use Hot instead of cool if you wish to move the blobs to Hot tier.
        $blob.ICloudBlob.SetStandardBlobTier("Cool"); 
    }

 }
 While ($Token -ne $Null)

 Echo "Total $Total blobs are being rehydrated."
