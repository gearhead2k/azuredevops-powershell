param(
    [string]$Organization,
    [string[]]$ProjectsFilter = @(),
    [string[]]$ProjectsExclusionFilter = @(),
    [string]$ConfigurationPath = "../configFiles/connection-config.json"
)

$indent = "  "
$scriptWorkingDir = Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent
$baseScriptDir = Join-Path -Path $scriptWorkingDir -ChildPath ".."
. $baseScriptDir\common\config\config-functions.ps1
. $baseScriptDir\common\resources\project-functions.ps1
. $baseScriptDir\common\resources\git-functions.ps1
. $baseScriptDir\common\resources\gitRef-functions.ps1
. $baseScriptDir\common\requests\url-functions.ps1

$connectionConfig = Get-JsonConfiguration -ConfigurationPath $ConfigurationPath -BaseScriptDirectory $baseScriptDir
$filteredProjectList = List-AzDoProjects -ConnectionConfig $connectionConfig -Organization $Organization -ProjectsFilter $ProjectsFilter -ProjectsExclusionFilter $ProjectsExclusionFilter
$initpath = get-location

$filteredProjectList | ForEach-Object {
    $project = $_
    Write-Host $_.name -ForegroundColor Yellow
    $gitRepos = List-GitRepositories  -ConnectionConfig $connectionConfig -Organization $Organization -Project $project.name
    
    $gitRepos | ForEach-Object {
        $gitRepo = $_
        $gitUrl = Replace-GitUrlWithCreds -ConnectionConfig $connectionConfig -Url $gitRepo.remoteUrl -Organization $Organization
        $repoLocalDir = Join-Path -Path (Join-Path -Path $connectionConfig.baseDirectory -ChildPath $project.name) -ChildPath $gitRepo.name

        Write-Host "$($indent)$($gitRepo.name)" -ForegroundColor Blue
        
        if (!(Test-Path -Path $repoLocalDir)) {
            Write-Host "$($indent)$($indent)Not Found"
            git clone "$($gitUrl)" "$($repoLocalDir)"
        }
        else {
            Write-Host "$($indent)$($indent)Found" -ForegroundColor Magenta
        }

        try {
            set-location $repoLocalDir

            Write-Host $gitRepo.id
            $branches = List-GitRef -ConnectionConfig $connectionConfig -Organization $Organization -Project $project.name -RepositoryId $gitRepo.id -IncludeBranches $connectionConfig.includeBranches -ExcludeBranches $connectionConfig.excludeBranches
            $branch
            $branches | ForEach-Object {
                $branch = $_
                Write-Host "$($indent)$($indent)$($branch)" -ForegroundColor Cyan
                git checkout $branch
                git pull
            }
        }
        finally {
            set-location $initpath
        }

        
    }
}