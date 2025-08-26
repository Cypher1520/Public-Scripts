try{
$response = ""
    $response = Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json' -ErrorVariable RespErr 
#$response = Invoke-RestMethod -Uri https://localhost:44377/explore/v2/Content?overwrite=true -Method Post -Body $PostData -Headers  $header -ErrorVariable RespErr 
Write-Host "Content created with url="$response.value[0] 

}
catch [System.Net.WebException] {   
        $respStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($respStream)
        $respBody = $reader.ReadToEnd() | ConvertFrom-Json
        $respBody;
 }