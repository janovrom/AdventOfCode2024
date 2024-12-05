$data = Get-Content .\data.txt

$edges = [System.Collections.Generic.HashSet[string]]::new()

function EvaluateUpdates($line, $edges) {
    $len = $updates.Length
    for ($i = 0; $i -lt $len; $i++) {
        for ($j = $i + 1; $j -lt $len; $j++) {
            $x = $updates[$i]
            $y = $updates[$j]
            if ($edges.Contains("$x|$y")) {
                # That's ok
            } else {
                # Might be ok, but check the reverse
                if ($edges.Contains("$y|$x")) {
                    # That's not ok
                    return $false
                }
            }
        }
    }

    # No issue found, it's ok
    return $true
}

$isRule = $true
$sum = 0
foreach ($line in $data) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        $isRule = $false
        continue
    }

    if ($isRule) {
        [void]$starts.Add($x)
        [void]$edges.Add($line)
    } else {
        $updates = $line.Split(',')
        $isCorrect = EvaluateUpdates $updates $edges

        if ($isCorrect) {
            $sum += $updates[[math]::Floor($updates.Length / 2)]
        }
    }
}

Write-Host $sum
Set-Clipboard $sum