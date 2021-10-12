function Start-Process { 
    param(
        [string]$ProcessName,
        [string]$Arguments,
        [string]$WorkingDirectory = ""
    )

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $ProcessName
    $processInfo.RedirectStandardError = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.Arguments = $Arguments

    if ($WorkingDirectory -ne "") {
        $processInfo.WorkingDirectory = $WorkingDirectory
    }
    Write-Warning "starting"
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null
    $process.WaitForExit(10000) | Out-Null

    Write-Warning "process complete - $($process.ExitCode) - $($proces.HasExited)"
    $process.StandardOutput
    if ($null -ne $process.StandardOutput) {
        $stdOut = $process.StandardOutput.ReadToEnd()
    }
    else {
        $stdOut = ""
    }
    if($null -ne $process.StandardError) {
    $stdErr = $process.StandardError.ReadToEnd()
    }
    else {
        $stdErr = ""
    }

    Write-Warning "output"

    $Output = New-Object PSObject
    Add-Member -InputObject @Output -MemberType NoteProperty -Name ExitCode -Value $process.ExitCode
    Add-Member -InputObject @Output -MemberType NoteProperty -Name StdOut -Value $stdOut
    Add-Member -InputObject @Output -MemberType NoteProperty -Name StdErr -Value $stdErr
    return $Output
}