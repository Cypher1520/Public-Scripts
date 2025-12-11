# Install the module if you don't have it
# Install-Module -Name ImportExcel -Scope CurrentUser

Import-Module ImportExcel

$AdmxFolder  = $PSScriptRoot
$AdmlLang    = "$PSScriptRoot\EN-US"
$OutputFile  = "$AdmxFolder\WindowsDefender_ADMX_All.xlsx"

# Create or clear workbook
if (Test-Path $OutputFile) { Remove-Item $OutputFile }

# Loop through each ADMX file
Get-ChildItem $AdmxFolder -Filter *.admx | ForEach-Object {

    $AdmxPath = $_.FullName
    $AdmlPath = Join-Path $AdmxFolder "$AdmlLang\$($_.Name.Replace('.admx','.adml'))"

    if (-not (Test-Path $AdmlPath)) {
        Write-Warning "No matching ADML for $($_.Name), skipping."
        return
    }

    Write-Host "Processing $($_.Name)..."

    # Load XML files
    [xml]$admx = Get-Content -Path $AdmxPath
    [xml]$adml = Get-Content -Path $AdmlPath

    # Namespace managers
    $nsMgrAdmx = New-Object System.Xml.XmlNamespaceManager($admx.NameTable)
    $nsMgrAdmx.AddNamespace("def", $admx.DocumentElement.NamespaceURI)

    $nsMgrAdml = New-Object System.Xml.XmlNamespaceManager($adml.NameTable)
    $nsMgrAdml.AddNamespace("def", $adml.DocumentElement.NamespaceURI)

    # Build string lookup table from ADML
    $strings = @{}
    $admlStrings = $adml.SelectNodes("//def:stringTable/def:string", $nsMgrAdml)
    foreach ($s in $admlStrings) { $strings[$s.id] = $s.'#text' }

    function Resolve-String {
        param([string]$ref)
        if ($null -eq $ref) { return "" }
        if ($ref -match '^\$\((?:string\.)?(.+?)\)$') {
            $id = $Matches[1]
            if ($strings.ContainsKey($id)) { return $strings[$id] }
            else { return $ref }
        }
        return $ref
    }

    # Get all <policy> nodes
    $policyNodes = $admx.SelectNodes("//def:policy", $nsMgrAdmx)
    if (-not $policyNodes -or $policyNodes.Count -eq 0) {
        $policyNodes = $admx.SelectNodes("//def:policyDefinition", $nsMgrAdmx)
    }

    if (-not $policyNodes -or $policyNodes.Count -eq 0) {
        Write-Warning "No policies found in $($_.Name), skipping."
        return
    }

    # Build policy objects
    $policies = foreach ($policy in $policyNodes) {
        [PSCustomObject]@{
            Name        = $policy.name
            DisplayName = Resolve-String $policy.displayName
            Class       = $policy.class
            Key         = $policy.key
            ValueName   = $policy.valueName
            ExplainText = Resolve-String $policy.explainText
        }
    }

    # Export to Excel sheet (sheet name = ADMX filename without extension)
    $SheetName = $_.BaseName
    $policies | Export-Excel -Path $OutputFile -WorksheetName $SheetName -AutoSize -BoldTopRow -Append
}

Write-Host "✅ All ADMX files exported to: $OutputFile"