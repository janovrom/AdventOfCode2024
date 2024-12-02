$data = Get-Content .\data.txt

function IsSafe($levels){
    for ($i = 0; $i -lt $levels.Length - 1; $i++) {
        $level0 = $levels[$i]
        $level1 = $levels[$i + 1]

        $levels[$i] = $level0 - $level1
    }

    if ($levels[0] -eq 0) {
        return $false
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
            return $false
        } elseif ($levels[$i] -eq 0) {
            return $false
        }
    }

    return $true
}

$safeReportCount = 0
foreach ($line in $data) {
    $levels = $line.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object {
        [int]$_
    }

    $isSafe = $false
    for ($i = -1; $i -lt $levels.Length; $i++) {
        if ($i -eq -1) {
            $newlevels = $levels[0..($levels.Length - 1)]
        } elseif ($i -eq $levels.Length - 1) {
            $newlevels = $levels[0..($levels.Length - 2)]
        } elseif ($i -eq 0) {
            $newlevels = $levels[1..($levels.Length - 1)]
        }  else {
            $newlevels = $levels[0..($i - 1)] + $levels[($i + 1)..($levels.Length - 1)]
        }
        $isSafe = IsSafe($newlevels)
        if ($isSafe) {
            break
        }
    }

    if ($isSafe) {
        $safeReportCount++
    }
}

Write-Host $safeReportCount
Set-Clipboard $safeReportCount