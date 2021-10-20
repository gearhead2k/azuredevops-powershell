function Get-IndentedText { 
    param(
        [string]$Text,
        [string]$Indent = "  " ,
        [ValidateRange(0, 100)]
        [int32]$NumberIndents
    )

    if ($NumberIndents -eq 0) {
        return $Text;
    }
        
    $indentText = ""
    for ($i = 1; $i -le $NumberIndents; $i++) {
        $indentText += $Indent
    }

    return "$($indentText)$($Text)"
}

function Get-FirstLettersOfAllWords {
    param(
        [string]$Text,
        [string]$SplitSeparator = " "
    )

    if ($null -eq $Text) {
        Write-Error "Value cannot be null" -ErrorAction Stop
    }

    $values = ($Text.Trim()) -split $SplitSeparator;
    $tmpValue = ""

    if ($values.Length -eq 0) {
        Write-Error "No values found." -ErrorAction Stop
    }

    $values | ForEach-Object {
        $word = $_
        if ($word.length -gt 0) {
            $initial = $word[0];
        }
        else {
            $initial = ""
        }

        $tmpValue = "$($tmpValue)$($initial)"
    }

    return $tmpValue
}