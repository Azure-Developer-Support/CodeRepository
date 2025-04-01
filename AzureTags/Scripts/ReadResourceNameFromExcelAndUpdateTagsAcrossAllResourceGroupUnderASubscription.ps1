/*DISCLAIMER: The sample custom policies are not supported under any Microsoft standard support program or service. 
This is intended to be used in non-production environment only. The sample scripts are provided AS IS without warranty of any kind.
Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
In no event shall Microsoft, its authors, owners of this blog, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages
whatsoever (including without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out
of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.*/

/*Description: This script helps in replacing tag value with the new value fetched from excel.  */


#CSV file that contains the resource name and tag value column (NewTag). NewTag column's value is picked up by the script and is used to replace the existing value.
$data = Import-Csv -Path "PATH_TO_CSV_FILE.csv"
$subResourceGroups = Get-AzResourceGroup

foreach($rg in $subResourceGroups)
{
  $resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName
  $rgData = $data | Where-Object { $_.ResourceGroup -eq $rg.ResourceGroupName }
  
  foreach ($dat in $rgData) 
  {
    $resource = $resources | Where-Object { $_.Name -eq $dat.NAME }
      if($resource.Count )
        {
          foreach($res in $resource)
          {
            $hash = @{};
            $hash.Add("TAG_NAME",$dat.NewTag)
            Update-AzTag -ResourceId $res.ResourceId -Tag $hash -Operation Replace
          }
       }
       else
        {
          $hash = @{};
          $hash.Add("TAG_NAME",$dat.NewTag)
          Update-AzTag -ResourceId $resource.ResourceId -Tag $hash -Operation Replace
       }
    }
}
