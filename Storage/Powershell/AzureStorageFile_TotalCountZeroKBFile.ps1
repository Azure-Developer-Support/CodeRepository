#Azure Storage FileShare - PowerShell
###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########These scripts provide total number of blobs based on Tier for a storage account #########################



$storageAccountName = "<Storage-Account-Name>"
$storageAccountKey = "<SAS-KEY>

$shareName = "<File-Share-Name>"

$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

$list = Get-AzStorageFile -ShareName $shareName -Context $ctx | Select-Object -Property Name, Length, mainDir

Write-Host "Started: " -ForegroundColor White

$totalCount = 0
$size = $list.Count

for($i = 0; $i -lt $size; $i++)
{
    Write-Host "File/Dir Name: " $list[$i].Name -ForegroundColor Yellow
    
    if ($null -eq $list[$i].Length)
    {
        Write-Host "Directory: " $list[$i].Name "found!" -ForegroundColor Red
        
        Write-Host "adding its subdirectories & files ..." -ForegroundColor White

        try {
            $subfile = Get-AzStorageFile -ShareName $shareName -Context $ctx -Path ($list[$i].mainDir + $list[$i].Name) -ErrorAction Continue | Get-AzStorageFile | Select-Object -Property Name, Length, mainDir 

            foreach ($item in $subfile)
            {
                $item.mainDir += $list[$i].mainDir + $list[$i].Name + "/"
            }
            $size += $subfile.Count
            $list += $subfile
            # adding sub directories with updated path
        }
        catch {
            Write-Error "Found Error!!!!"
            continue
        }
    
    }elseif ($list[$i].Length -eq 0){
        Write-Host "Zero KB file found!" -ForegroundColor Green
        $totalCount += 1    }
    
    
        Write-Host ""
}

Write-Host "Total Zero KB file in FileShare: " $shareName " = " $totalCount -ForegroundColor Blue

