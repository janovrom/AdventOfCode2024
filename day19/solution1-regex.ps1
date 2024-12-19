Import-Module .\data-loader.ps1

$data = LoadData

$sum = 0
foreach ($arrangement in $data.arrangements) {
    # Check if the arrangement can be made from the patterns
    # First find candidates. Candidate is a pattern that occurs in the arrangement
    $candidates = @()
    foreach ($pattern in $data.patterns) {
        if ($arrangement -match $pattern) {
            $candidates += $pattern
        }
    }

    # If there are no candidates, the arrangement cannot be made from the patterns
    if ($candidates.Count -eq 0) {
        continue
    }

    # Construct a regex pattern from the candidates
    $regexPattern = "^($($candidates -join '|'))+$"
    if ($arrangement -match $regexPattern) {
        $sum += 1
    }

    Write-Host "Finished processing $arrangement"
}

Write-Host $sum
Set-Clipboard $sum