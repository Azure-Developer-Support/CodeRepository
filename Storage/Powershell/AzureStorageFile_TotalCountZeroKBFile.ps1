#Azure Storage FileShare - PowerShell

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

