$data = Get-Content .\data.txt

$matrix = @()
foreach ($line in $data) {
    $matrix += ,($line.ToCharArray() | ForEach-Object { [int]"$_" })
}

$starts = @()

for ($i = 0; $i -lt $matrix.Length; $i++) {
    for ($j = 0; $j -lt $matrix[$i].Length; $j++) {
        if ($matrix[$i][$j] -eq 0) {
            $sx = $i
            $sy = $j
            $starts += ,($sx, $sy, 0, 0, 0, 0)
        }
    }
}

$sum = 0
foreach ($start in $starts) {
    $visited = [System.Collections.Generic.HashSet[object]]::new()
    $queue = [System.Collections.Generic.Stack[object]]::new()
    [void]$queue.Push($start)
    $trailScore = 0
    while ($queue.Count -gt 0) {
        $node = $queue.Pop()
        [int]$x = $node[0]
        [int]$y = $node[1]
        [int]$l = $node[2]
        [int]$px = $node[3]
        [int]$py = $node[4]
        [int]$pl = $node[5]

        # Skip outside the bounds
        if ($x -lt 0 -or $x -ge $matrix.Length -or $y -lt 0 -or $y -ge $matrix[$x].Length) {
            continue
        }

        # We expect some value in the matrix (height), skip otherwise
        if ($matrix[$x][$y] -ne $l) {
            continue
        }

        # Skip if already visited
        if ($visited.Contains(@($x, $y, $px, $py))) {
            continue
        }

        # mark as visited
        [void]$visited.Add(@($x, $y, $px, $py))

        # Mark path longer than 9 (it should be impossible)
        if ($l -gt 9) {
            continue
        }

        # Found the end
        if ($l -eq 9 -and $matrix[$x][$y] -eq 9) {
            $trailScore += 1
            continue
        }

        # Mark as visited and do the visit

        # Add the neighbors
        [void]$queue.Push(@(($x + 1), $y, ($l + 1)))
        [void]$queue.Push(@(($x - 1), $y, ($l + 1)))
        [void]$queue.Push(@($x, ($y + 1), ($l + 1)))
        [void]$queue.Push(@($x, ($y - 1), ($l + 1)))
    }

    $sum += $trailScore
}

Write-Host $sum
Set-Clipboard $sum