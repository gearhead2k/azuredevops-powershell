function List-GitRepositories {
    param(
        [PSCustomObject]$config,
        [string]$Organization,
        [string]$Project
    )

    $scriptBase = $config.BaseScriptDirectory
    . $scriptBase\common\requests\azdo-functions.ps1
    . $scriptBase\common\requests\url-functions.ps1

    $replaceValues = New-Object PSObject
    Add-Member -InputObject @replaceValues -MemberType NoteProperty -Name Organization -Value $Organization
    Add-Member -InputObject @replaceValues -MemberType NoteProperty -Name Project -Value $Project
    $gitRepoListEndpoint = Replace-AzDoUrlParameters -Url $config.EndpointUrls.gitRepoListEndPoint -Values $replaceValues
    $apiToken = $config.apiToken

    $gitRepoListRequest = Call-AzDevOps -EndPoint $gitRepoListEndpoint -ApiToken $ApiToken
    if ($gitRepoListRequest.StatusCode -ne 200) {
        Write-Error "Error retrieving git repository list" -ErrorAction Stop
        exit
    }

    $gitRepoList = $($gitRepoListRequest.Content | ConvertFrom-Json).value

    $gitRepoList
}

