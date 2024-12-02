$data = Get-Content .\data.txt

$safeReportCount = 0
foreach ($line in $data) {
    $levels = $line.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object {
        [int]$_
    }

    $isSafe = $true
    for ($i = 0; $i -lt $levels.Length - 1; $i++) {
        $level0 = $levels[$i]
        $level1 = $levels[$i + 1]

        $levels[$i] = $level0 - $level1
    }

    if ($levels[0] -eq 0) {
        $isSafe = $false
        continue
    }

    $isIncreasing = $levels[0] -gt 0

    $min = 0
    $max = 0

    if ($isIncreasing) {
        $min = 1
        $max = 3
    } else {
        $min = -3
        $max = -1
    }

    for ($i = 0; $i -lt $levels.Length - 1; $i++) {
        if ($levels[$i] -lt $min -or $levels[$i] -gt $max) {
            $isSafe = $false
            break
        } elseif ($levels[$i] -eq 0) {
            $isSafe = $false
            break
        }
    }

    if ($isSafe) {
        $safeReportCount++
    }
}

Write-Host $safeReportCount
Set-Clipboard $safeReportCount