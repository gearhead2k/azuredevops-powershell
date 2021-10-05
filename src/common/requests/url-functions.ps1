function Replace-AzDoUrlParameters {
    param(
        [string]$Url,
        $Values
    )
    $newUrl = $Url

    if ($Values.PSobject.Properties.name -match "Organization") {
        $newUrl = $newUrl.Replace("{organization}",$Values.Organization)
    }

    if ($Values.PSobject.Properties.name -match "Project") {
        $newUrl = $newUrl.Replace("{project}",$Values.Project)
    }

    if ($Values.PSobject.Properties.name -match "RepositoryId") {
        $newUrl = $newUrl.Replace("{repositoryId}",$Values.RepositoryId)
    }

    $newUrl
}

function Replace-GitUrlWithCreds {
    param(
        [PSCustomObject]$connectionConfig,
        [string]$Url,
        [string]$Organization
    )

    $gitcred = ("{0}:{1}" -f  [System.Web.HttpUtility]::UrlEncode($connectionConfig.apiUser),$connectionConfig.apiToken)
    
    $baseUrl = $Url -replace "://$($Organization)@", "://" 
    $gitUrl = $baseUrl -replace "://", ("://{0}@" -f $gitcred)

    $gitUrl
}