. ".\data-loader.ps1"

$data = LoadData

function IsValid($current, $candidates, $unresolvable) {
    if ($current.Length -eq 0) {
        return $true
    }

    if ($unresolvable.Contains($current)) {
        return $false
    }

    foreach ($candidate in $candidates) {
        if ($current.StartsWith($candidate)) {
            if (IsValid $current.Substring($candidate.Length) $candidates $unresolvable) {
                return $true
            }
        }
    }

    # This current arrangement cannot be made from the patterns
    # Mark it as unresolvable

    [void]$unresolvable.Add($current)

    return $false
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

    $unresolvable = New-Object System.Collections.Generic.HashSet[string]
    if (IsValid $arrangement $candidates $unresolvable) {
        $sum += 1
    }

    Write-Host "Finished processing $arrangement"
}

Write-Host $sum
Set-Clipboard $sum