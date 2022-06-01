#The below PowerShell script helps to delete the version on a specific conatiner 
#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, 
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

$storageAccountName="storage account name"
$StorageAccountKey = "access keys"
$containerName = "container Name"
$sctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey
$blob_continuation_token = $null

$blobs=Get-AzStorageBlob -context $sctx -Container $containerName -IncludeVersion -ContinuationToken $blob_continuation_token

do {

$blob_continuation_token = $null;
if ($blobs -ne $null)
{

$blob_continuation_token = $blobs[$blobs.Count - 1].ContinuationToken

for ([int] $b = 0; $b -lt $blobs.Count; $b++)
{
If (($blobs[$b].VersionId) -ne $null -and !($blobs[$b].IsLatestVersion))
{

Remove-AzStorageBlob -context $sctx -Container $containerName -Blob $blobs[$b].Name -VersionId $blobs[$b].VersionId
}
}
If ($blob_continuation_token -ne $null)
{
Write-Verbose "Blob listing continuation token = {0}".Replace("{0}",$blob_continuation_token.NextMarker)
}
}
} while ($blob_continuation_token.NextMarker.Length -ne 0)
