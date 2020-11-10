# DISCLAIMER #
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
#The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. 
#In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages   


  #The Below script is useful to tackle issue that you may face when when you encounter errors such as :#
  #Invalid Block/Blob 'The specified blob or block content is invalid' #
  #The uncommitted block count cannot exceed the maximum limit of 100,000 blocks ErrorCode:BlockCountExceedsLimit #
  #Invalid Block 'The specified block list is invalid'#
 
 #This Script would help in Performing a GetBlockList (with blocklisttype=uncommitted) to retrieve the uncommitted block list and then delete the blob. #

  [CmdletBinding()]
Param(
  #Please enter storage account name
  [Parameter(Mandatory=$true,Position=1)] [string] $StorageAccountName,
  #Please enter Shared Access Signature <SAS token > generated with the permissions <ss=b;srt=sco;sp=rwldc>
  [Parameter(Mandatory=$True,Position=1)] [string] $SharedAccessSignature,
  #Please enter storage Container name
  [Parameter(Mandatory=$True,Position=1)] [string] $ContainerName ,
  #Please enter Blob name
  [Parameter(Mandatory=$True,Position=1)] [string] $Blobname
   )

# below rest API helps in getting the uncommitted block List 
$Blob = "https://$StorageAccountName.blob.core.windows.net/"+$ContainerName+"/"+$Blobname+"$SharedAccessSignature&comp=blocklist&blocklisttype=uncommitted"
$Blob
$listfileURI =  Invoke-WebRequest -Method Get -Uri $Blob

$FilesystemName = $listfileURI.Content
$String=$FilesystemName -replace 'ï»¿' , ''
$String | Select-Xml –Xpath “/BlockList/UncommittedBlocks/Block”|Select-Object -Expand Node 
$Count=$String.Count

#deletion of the blob & uncommitted block
if($Count.Count -gt 0)
{
$delete= "https://$StorageAccountName.blob.core.windows.net/"+$ContainerName+"/"+$Blobname+"$SharedAccessSignature"
$listfileURI1 =  Invoke-WebRequest -Method Delete -Uri $delete
$FilesystemName1 = $listfileURI1.StatusCode
Write-Host "Deletion has been successfully , API returned status code " $FilesystemName1
}
Write-Host "Check if the uncommitted block are still present"

Try
{
$Blobcheck = "https://$StorageAccountName.blob.core.windows.net/"+$ContainerName+"/"+$Blobname+"$SharedAccessSignature&comp=blocklist&blocklisttype=uncommitted"
$listfileURI2 =  Invoke-WebRequest -Method Get -Uri $Blobcheck
}
catch{
#$err=$_.Exception
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
}
Write-Host "With the above error message we can confirm that the uncommitted blocks and their respective blob has been deleted"
Write-Host "Name and size of uncommitted block that has been deleted are as below"

