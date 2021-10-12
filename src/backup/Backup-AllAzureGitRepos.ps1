param(
    [string]$Organization,
    [string[]]$ProjectsFilter = @(),
    [string[]]$ProjectsExclusionFilter = @(),
    [string]$ConfigurationPath = "../configFiles/config.json"
)

$indent = "  "
$scriptWorkingDir = Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent
$baseScriptDir = Join-Path -Path $scriptWorkingDir -ChildPath ".."
. $baseScriptDir\common\config\config-functions.ps1
. $baseScriptDir\common\config\config-validation-functions.ps1
. $baseScriptDir\common\resources\project-functions.ps1
. $baseScriptDir\common\resources\git-functions.ps1
. $baseScriptDir\common\resources\gitRef-functions.ps1
. $baseScriptDir\common\requests\url-functions.ps1
. $baseScriptDir\common\utils\process-management-functions.ps1
. $baseScriptDir\common\utils\string-functions.ps1

$config = Get-JsonConfiguration -ConfigurationPath $ConfigurationPath -BaseScriptDirectory $baseScriptDir
$config = Validate-Config -Config $config
$filteredProjectList = List-AzDoProjects -Config $config -Organization $Organization -ProjectsFilter $ProjectsFilter -ProjectsExclusionFilter $ProjectsExclusionFilter
$initpath = get-location

$filteredProjectList | ForEach-Object {
    $project = $_
    Write-Host $_.name -ForegroundColor Yellow
    $gitRepos = List-GitRepositories  -Config $config -Organization $Organization -Project $project.name
    
    $gitRepos | Sort-Object -Property "name" | ForEach-Object {
        $gitRepo = $_
        $gitUrl = Replace-GitUrlWithCreds -Config $config -Url $gitRepo.remoteUrl -Organization $Organization

        if ($config.useProjectInitials -and $project.name.length -gt $config.projectInitialLength) {
            $projectDir = Get-FirstLettersOfAllWords -Text $project.name
        }
        else {
            $projectDir = $project.name
        }

        $repoLocalDir = Join-Path -Path (Join-Path -Path $config.baseDirectory -ChildPath $projectDir) -ChildPath $gitRepo.name

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

            $branches = List-GitRef -Config $config -Organization $Organization -Project $project.name -RepositoryId $gitRepo.id -IncludeBranches $config.includeBranches -ExcludeBranches $config.excludeBranches
            $branches | ForEach-Object {
                $branch = $_
                Write-Host "$($indent)$($indent)$($branch)" -ForegroundColor Cyan
                # $output = Start-Process -ProcessName "git" -Arguments " checkout $($branch)" -WorkingDirectory $repoLocalDir
                # Write-Host (Get-IndentedText -Text $output.StdOut -NumberIndents 3) -ForegroundColor Green
                # Write-Host (Get-IndentedText -Text $output.StdErr -NumberIndents 3) -ForegroundColor Red
                
                # $outputPull = Start-Process -ProcessName "git" -Arguments " pull" -WorkingDirectory $repoLocalDir
                # Write-Host (Get-IndentedText -Text $outputPull.StdOut -NumberIndents 3) -ForegroundColor Green
                # Write-Host (Get-IndentedText -Text $outputPull.StdErr -NumberIndents 3) -ForegroundColor Red

                git checkout $branch 
                git pull
            }
        }
        finally {
            set-location $initpath
        }

        
    }
}