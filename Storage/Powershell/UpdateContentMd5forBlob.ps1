###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########The script helps you update "ContentMD5" property for the blob #########################


Connect-AzAccount
Select-AzSubscription -SubscriptionId 'subscription-Id'
$ctx = New-AzStorageContext -StorageAccountName 'storage-account-name' -UseConnectedAccount 
 
$blob =Get-AzStorageBlob -Context $ctx -Container "container-name" -Blob "samp1.txt" 

$blob.ICloudBlob.FetchAttributes()
$blob.ICloudBlob.Properties.ContentMD5 

$blob.ICloudBlob.Properties.ContentMD5 = "md5 calculated value"
$blob.ICloudBlob.SetPropertiesAsync() 
