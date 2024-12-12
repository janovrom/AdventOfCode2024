$data = Get-Content .\data.txt

$visited = @()
foreach ($line in $data) {
    $visited += ,(@($false) * $line.Length)
}

$sum = 0
for ($i = 0; $i -lt $data.Length; $i++) {
    for ($j = 0; $j -lt $data[$i].Length; $j++) {
        if ($visited[$i][$j]) {
            continue
        }

        $x = $data[$i][$j]
        $queue = New-Object System.Collections.Queue
        $queue.Enqueue(($i,$j))
        $group = [System.Collections.Generic.HashSet[object]]::new()
        while ($queue.Count -gt 0) {
            $cell = $queue.Dequeue()

            if ($cell[0] -lt 0 -or $cell[0] -ge $data.Length) {
                continue
            }

            if ($cell[1] -lt 0 -or $cell[1] -ge $data[$cell[0]].Length) {
                continue
            }

            if ($data[$cell[0]][$cell[1]] -ne $x) {
                continue
            }

            if ($visited[$cell[0]][$cell[1]]) {
                continue
            }

            $visited[$cell[0]][$cell[1]] = $true
            $group += ,$cell

            $queue.Enqueue((($cell[0]-1),$cell[1]))
            $queue.Enqueue((($cell[0]+1),$cell[1]))
            $queue.Enqueue(($cell[0],($cell[1]-1)))
            $queue.Enqueue(($cell[0],($cell[1]+1)))
        }

        $area = $group.Length
        $perimeter = $area * 4
        foreach ($cell in $group) {
            if ($cell[0] -gt 0 -and $data[$cell[0]-1][$cell[1]] -eq $x) {
                $perimeter--
            }
            if ($cell[0] -lt $data.Length - 1 -and $data[$cell[0]+1][$cell[1]] -eq $x) {
                $perimeter--
            }
            if ($cell[1] -gt 0 -and $data[$cell[0]][$cell[1]-1] -eq $x) {
                $perimeter--
            }
            if ($cell[1] -lt $data[$cell[0]].Length - 1 -and $data[$cell[0]][$cell[1]+1] -eq $x) {
                $perimeter--
            }
        }

        $sum += $area * $perimeter
    }
}

Write-Host $sum
Set-Clipboard $sum