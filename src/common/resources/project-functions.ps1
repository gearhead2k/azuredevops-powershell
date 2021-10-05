function List-AzDoProjects {
    param(
        [PSCustomObject]$connectionConfig,
        [string]$Organization,
        [string[]]$ProjectsFilter = @(),
        [string[]]$ProjectsExclusionFilter = @()
    )
    $scriptBase = $connectionConfig.BaseScriptDirectory
    . $scriptBase\common\requests\azdo-functions.ps1
    . $scriptBase\common\requests\url-functions.ps1

    $replaceValues = New-Object PSObject
    Add-Member -InputObject @replaceValues -MemberType NoteProperty -Name Organization -Value $Organization
    $projectListEndpoint = Replace-AzDoUrlParameters -Url $connectionConfig.EndpointUrls.projectListEndPoint -Values $replaceValues
    $apiToken = $connectionConfig.apiToken

    $projectListRequest = Call-AzDevOps -EndPoint $projectListEndpoint -ApiToken $ApiToken
    if ($projectListRequest.StatusCode -ne 200) {
        Write-Error "Error retrieving project list" -ErrorAction Stop
        exit
    }

    $projectCollecton = ($projectListRequest.Content | ConvertFrom-Json).value
    
    if (($ProjectsFilter | Where-Object { $null -ne $_ } | Measure-Object).Count -gt 0 ) {
        $filteredProjectList = $projectCollecton | Where-Object { 
            $fproject = $_
        ($null -ne ($ProjectsFilter | Where-Object { $fproject.name -like $_ }))
        } | Sort-Object -Property name | Select-Object
    }
    else {
        $filteredProjectList = $projectCollecton
    }

    if (($ProjectsExclusionFilter | Where-Object { $null -ne $_ } | Measure-Object).Count -gt 0 ) {
        $filteredProjectList = $filteredProjectList | Where-Object { 
            $fproject = $_
        ($null -eq ($ProjectsExclusionFilter | Where-Object { $fproject.name -like $_ }))
        } | Sort-Object -Property name | Select-Object
    }

    $filteredProjectList
  
} 