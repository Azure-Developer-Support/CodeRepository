#The below PowerShell script helps you to copy ACL's of one file to another in ADLS Gen 2 storage account.

#By using the following materials or sample code you agree to be bound by the license terms below and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you are located, one of its affiliates) and you. Any materials (other than this sample code) we provide to you are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to use and modify the sample code and to reproduce and distribute the object code form of the sample code, provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the sample code." 
#Note : User should have sufficient permissions to create the directory in the storage account

$storageAccountName = "strorage0hns0lrs0stan"
$storageAccountKey = "key"
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

$filesystemName = "mycontainer"
$filePath = "mydir/file1"
$file = Get-AzDataLakeGen2Item -Context $ctx -FileSystem $filesystemName -Path $filePath 
$myacl = $file.ACL 

for ($var = 0; $var -lt $myacl.Length; $var++)
{
   $perm = ""

    if($file.ACL[$var].Permissions -like "*Read*") { 
        $perm = "r"
    }
    else {
    $perm = "-"
    }

    if($file.ACL[$var].Permissions -like "*Write*") { 
        $perm = $perm+"w"
    }
    else {
    $perm = $perm+"-"
    }

    if($file.ACL[$var].Permissions -like "*Execute*") { 
        $perm = $perm+"x"
    }
    else {
    $perm = $perm+"-"
    }

    if($var -eq 0)
    {
        if($file.ACL[$var].EntityId -eq $null)     {
            $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $file.ACL[$var].AccessControlType -Permission $perm 
        }
        else{
            $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $file.ACL[$var].AccessControlType -Permission $perm -EntityId $file.ACL[$var].EntityId 
        }
    }
    else{    

        if($file.ACL[$var].EntityId -eq $null)     {
            $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $file.ACL[$var].AccessControlType -Permission $perm -InputObject $acl
        }
        else{
            $acl = Set-AzDataLakeGen2ItemAclObject -AccessControlType $file.ACL[$var].AccessControlType -Permission $perm -EntityId $file.ACL[$var].EntityId -InputObject $acl
        }
    }

    if($var -eq $file.ACL.Length-1)
    {        
        Update-AzDataLakeGen2Item -FileSystem $filesystemName -Path "mydir/file2" -ACL $acl -Context $ctx
    }
}
