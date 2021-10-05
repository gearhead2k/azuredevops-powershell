function Call-AzDevOps 
{ 
    param(
        [string]$EndPoint,
        [string]$ApiToken,
        [string]$Method = "GET",
        [parameter(Mandatory=$false)]
        $Body
    )

    $pair = "$($ApiToken):"
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
    
    $basicAuthValue = "Basic $($encodedCreds)"
    $headers = @{
        Authorization = $basicAuthValue; 
        'Accept' = 'application/json';
        'Content-Type' = 'application/json';
    }

    if ($Method -eq "POST" -or $Method -eq "PUT" -or $Method -eq "PATCH") {
        if ($PSBoundParameters.ContainsKey('Body') -ne $true) {
            Write-Error "Body not specified"
        } else {
            $request = Invoke-WebRequest $EndPoint -Headers $headers -Method $Method -Body $Body
        }
    } else {
        $request = Invoke-WebRequest $EndPoint -Headers $headers
    }

    $request
}