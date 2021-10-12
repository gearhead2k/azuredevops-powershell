function Validate-Config {
    param (
        [PSCustomObject]$config
    )

    if ($null -eq $config) {
        Write-Error "Config is null" -ErrorAction Stop
    }

    if ($config.PSobject.Properties.name -eq "useProjectInitials") {
        if ($config.useProjectInitials -eq "") {
            $config.useProjectInitials = $false;
        } 
    }
    else {
        Add-Member -InputObject $config -MemberType NoteProperty -Name useProjectInitials -Value $false
    }

    if ($config.PSobject.Properties.name -eq "projectInitialLength") {
        if ($config.projectInitialLength -eq "") {
            $config.projectInitialLength = 20;
        } 
    }
    else {
        Add-Member -InputObject $config -MemberType NoteProperty -Name projectInitialLength -Value 20
    }
    

    return $config
}
