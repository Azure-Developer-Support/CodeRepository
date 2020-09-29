###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 
 #############Script Overview#################################################################
##########This script provide helps finding the missing metadata keys of all blob files of a contianer and to update it#########################



$StorageAccountName ="<Storage Account Name>" #storage Account Name
$StorageAccountKey ="<Storage Account key>" #Storage Account Key
$ContainerName ="<container name>"  # Container Name
$Context =New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

#This will list all the blobs inside a container which do not have the 'customkey' metedata in it
$Blobs =Get-AzureStorageBlob -Container $ContainerName  -Context $Context | Where-Object {!$_.ICloudBlob.Metadata.ContainsKey("customkey")}

#This will list all the blobs inside a container which do  have the 'customkey' metedata and but have empty '' values in the 'customkey' metadata. you can chnage the empty values to any values you want to compare against
$BlobsWithEmptyMetadata =Get-AzureStorageBlob -Container $ContainerName  -Context $Context | Where-Object {$_.ICloudBlob.Metadata.ContainsKey("customkey")} |  Where-Object {$_.ICloudBlob.Metadata["customkey"] -eq ""}


#Then loop through each blob which are missing specific metadata key to do the operation you want. I am just listing the name of each blob here.  
     foreach ($Blob in $Blobs)
    { 

       echo $Blob.Name
    }

    # loop through each blob which have empty values in specific metadata key to do the operation you want. I am just listing the name of each blob here.  
     foreach ($Blob in $BlobsWithEmptyMetadata)
    { 

       echo $Blob.Name
    } 

