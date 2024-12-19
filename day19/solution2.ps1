. ".\data-loader.ps1"

$data = LoadData

function IsValid($current, $candidates, $resolved) {
    if ($current.Length -eq 0) {
        return 1
    }

    if ($resolved.ContainsKey($current)) {
        return $resolved[$current]
    }

    $sum = 0
    foreach ($candidate in $candidates) {
        if ($current.StartsWith($candidate)) {
            $sum += (IsValid $current.Substring($candidate.Length) $candidates $resolved)
        }
    }

    # This current arrangement cannot be made from the patterns
    # Mark it as unresolvable

    [void]$resolved.Add($current, $sum)

    return $sum
}

$sum = 0
foreach ($arrangement in $data.arrangements) {
    # Check if the arrangement can be made from the patterns
    # First find candidates. Candidate is a pattern that occurs in the arrangement
    $candidates = New-Object System.Collections.Generic.HashSet[string]
    foreach ($pattern in $data.patterns) {
        if ($arrangement -match $pattern) {
            [void]$candidates.Add($pattern)
        }
    }

    # If there are no candidates, the arrangement cannot be made from the patterns
    if ($candidates.Count -eq 0) {
        continue
    }

    $resolved = New-Object 'System.Collections.Generic.Dictionary[string,long]'
    $sum += (IsValid $arrangement $candidates $resolved)

    Write-Host "Finished processing $arrangement"
}

Write-Host $sum
Set-Clipboard $sum