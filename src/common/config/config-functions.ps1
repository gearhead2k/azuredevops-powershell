
function Get-JsonConfiguration {
    param (
        [string]$ConfigurationPath
    )

    if (!(Test-Path -Path $ConfigurationPath)) {
        Write-Error "Configuration file not found: $($ConfigurationPath)" -ErrorAction Stop
    }

    $configdata = Get-Content -Path $ConfigurationPath | ConvertFrom-Json
    Add-Member -InputObject $configdata -MemberType NoteProperty -Name BaseScriptDirectory -Value $baseScriptDir

    return $configdata
}