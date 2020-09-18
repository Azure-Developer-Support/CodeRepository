# DISCLAIMER #
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
#The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. 
#In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages   


  #This Script would help in calculating the size of each File system(container) in an ADLSGEN2 storage account #



  [CmdletBinding()]
Param(
  [Parameter(Mandatory=$true,Position=1)] [string] $StorageAccountName,
  #Please enter Shared Access Signature <SAS token > generated with the permissions <ss=b;srt=sco;sp=rwl>
  [Parameter(Mandatory=$True,Position=1)] [string] $SharedAccessSignature,
$totalSize ,
$continuationtoken = $null
) 

# Getting the List of Filesystem present in the storage account using REST API

$listfile= "https://$StorageAccountName.dfs.core.windows.net/$SharedAccessSignature&resource=account"
$listfileURI =  Invoke-WebRequest -Method Get -Uri $listfile
$FilesystemName = $listfileURI.Content|ConvertFrom-Json
$test1 = $FilesystemName.filesystems.name

foreach ($filesystem in $test1)
{
	do
		{
		#Retriving the properties of the all the files in the filsystem 
				$URI =  "https://$StorageAccountName.dfs.core.windows.net/"+$filesystem+"$SharedAccessSignature&recursive=true&resource=filesystem&continuation="+$continuationtoken+"&maxResults=1000”
				$webcont =  Invoke-WebRequest -Method Get -Uri $URI
				$continuationtoken =  $webcont.Headers.'x-ms-continuation'
				$json = $webcont.Content | ConvertFrom-Json
				$totalSize=0
		# Each Filesystem size calculation using REST API
				$totalSize = $totalSize  + ($json.paths.contentLength | Measure-Object -Sum).Sum
	} While ($continuationtoken -ne $null)

	  $sizeinGB = $totalSize/1GB 
	  Write-Host  "`n" "Total size of the $filesystem filesystem is | $totalSize Bytes| $sizeinGB GB" "`n"
	  Write-Host "==========================================================="
}
