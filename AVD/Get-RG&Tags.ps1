#connect to Azure and set the default sub
Connect-AzAccount
Set-AzContext -Subscription VDI-PRD
 
# Initialise output array
$Output = @()
 
# Collect all the groups from the current subscription
$ResourceGroups = Get-AzResourceGroup
 
# Obtain a unique list of tags for these groups collectively
$UniqueTags = $ResourceGroups.Tags.GetEnumerator().Keys | Sort-Object -Unique
 
# Loop through the resource groups
foreach ($ResourceGroup in $ResourceGroups) {
    # Create a new ordered hashtable and add the normal properties first.
    $RGHashtable = [ordered] @{}
    $RGHashtable.Add("Name", $ResourceGroup.ResourceGroupName)
    $RGHashtable.Add("Location", $ResourceGroup.Location)
    $RGHashtable.Add("Id", $ResourceGroup.ResourceId)
    $RGHashtable.Add("ProvisioningState", $ResourceGroup.ProvisioningState)
 
    # Loop through possible tags adding the property if there is one, adding it with a hyphen as it's value if it doesn't.
    if ($ResourceGroup.Tags.Count -ne 0) {
        $UniqueTags | Foreach-Object {
            if ($ResourceGroup.Tags[$_]) {
                $RGHashtable.Add("$_ (Tag)", $ResourceGroup.Tags[$_])
            }
            else {
                $RGHashtable.Add("$_ (Tag)", "-")
            }
        }
    }
    else {
        $UniqueTags | Foreach-Object { $RGHashtable.Add("$_ (Tag)", "-") }
    }
 
    # Update the output array, adding the ordered hashtable we have created for the ResourceGroup details.
    $Output += New-Object psobject -Property $RGHashtable
}
 
# Sent the final output to CSV
$Output | Export-Csv -Path C:\Temp\RGs.csv -NoClobber -NoTypeInformation -Encoding UTF8 -Force