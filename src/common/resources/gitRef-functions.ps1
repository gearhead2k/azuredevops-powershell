function List-GitRef {
    param(
        [PSCustomObject]$connectionConfig,
        [string]$Organization,
        [string]$Project,
        [string]$RepositoryId,
        [string[]]$IncludeBranches = @(),
        [string[]]$ExcludeBranches = @()
    )

    $scriptBase = $connectionConfig.BaseScriptDirectory
    . $scriptBase\common\requests\azdo-functions.ps1
    . $scriptBase\common\requests\url-functions.ps1

    $replaceValues = New-Object PSObject
    Add-Member -InputObject @replaceValues -MemberType NoteProperty -Name Organization -Value $Organization
    Add-Member -InputObject @replaceValues -MemberType NoteProperty -Name Project -Value $Project
    Add-Member -InputObject @replaceValues -MemberType NoteProperty -Name RepositoryId -Value $RepositoryId
    $gitRepoListEndpoint = Replace-AzDoUrlParameters -Url $connectionConfig.EndpointUrls.gitRefListEndPoint -Values $replaceValues
    $apiToken = $connectionConfig.apiToken

    $gitRefListRequest = Call-AzDevOps -EndPoint $gitRepoListEndpoint -ApiToken $ApiToken
    if ($gitRefListRequest.StatusCode -ne 200) {
        Write-Error "Error retrieving git reference list" -ErrorAction Stop
        exit
    }

    $gitRefList = $($gitRefListRequest.Content | ConvertFrom-Json).value

    $filteredGitRefList = $gitRefList | ForEach-Object {
        $_.name -replace "^refs/heads/", ""
    }

    if (($IncludeBranches | Where-Object { $null -ne $_ } | Measure-Object).Count -gt 0 ) {
        $filteredGitRefList = $filteredGitRefList | Where-Object { 
            $fBranch = $_
        ($null -ne ($IncludeBranches | Where-Object { $fBranch -like $_ }))
        }
    }

    if (($ExcludeBranches | Where-Object { $null -ne $_ } | Measure-Object).Count -gt 0 ) {
        $filteredGitRefList = $filteredGitRefList | Where-Object { 
            $fBranch = $_
        ($null -ne ($ExcludeBranches | Where-Object { $fBranch -notlike $_ }))
        } 
    }

    if (($ExcludeBranches | Where-Object { $null -ne $_ } | Measure-Object).Count -gt 0 ) {
    
            $filteredGitRefList = $filteredGitRefList | Where-Object { 
                $fBranch = $_
            ($null -eq ($ExcludeBranches | Where-Object { $fBranch -like $_ }))
            } 
        }

    $filteredGitRefList
}

