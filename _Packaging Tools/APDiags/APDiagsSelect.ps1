$select = Get-ChildItem .\Diags\

foreach ($i in $select) {
    Write-Host $select.IndexOf($i) - $i.Name
}
Write-host ""
Write-Host Select Diag "#: " -ForegroundColor Yellow -NoNewline
$pick = Read-Host
$script = ".\Diags\" + $select[$pick].name
Write-Output $script
& "$script"