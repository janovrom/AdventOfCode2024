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
        $edges = [System.Collections.Generic.HashSet[object]]::new()
        foreach ($cell in $group) {
            # Add all four edges of the cell to the set
            # 0,0 0,1
            # 1,0 1,1
            # Create vertices ccw from top left
            $v0 = ($cell[0],$cell[1])
            $v1 = (($cell[0]+1),$cell[1])
            $v2 = (($cell[0]+1),($cell[1]+1))
            $v3 = ($cell[0],($cell[1]+1))

            $e0 = [Tuple]::Create($v0[0], $v0[1], $v1[0], $v1[1])
            $e1 = [Tuple]::Create($v1[0], $v1[1], $v2[0], $v2[1])
            $e2 = [Tuple]::Create($v2[0], $v2[1], $v3[0], $v3[1])
            $e3 = [Tuple]::Create($v3[0], $v3[1], $v0[0], $v0[1])

            $re0 = [Tuple]::Create($v1[0], $v1[1], $v0[0], $v0[1])
            $re1 = [Tuple]::Create($v2[0], $v2[1], $v1[0], $v1[1])
            $re2 = [Tuple]::Create($v3[0], $v3[1], $v2[0], $v2[1])
            $re3 = [Tuple]::Create($v0[0], $v0[1], $v3[0], $v3[1])


            # XOR it. If it's already in the set, it's shared with other face.
            # Remember, it has to be reversed edge.
            if ($edges.Contains($re0)) {
                [void]$edges.Remove($re0)
            } else {
                [void]$edges.Add($e0)
            }

            if ($edges.Contains($re1)) {
                [void]$edges.Remove($re1)
            } else {
                [void]$edges.Add($e1)
            }

            if ($edges.Contains($re2)) {
                [void]$edges.Remove($re2)
            } else {
                [void]$edges.Add($e2)
            }

            if ($edges.Contains($re3)) {
                [void]$edges.Remove($re3)
            } else {
                [void]$edges.Add($e3)
            }
        }
        
        # Pick an edge and then remove all, that has the same direction
        # and are connected to the same group
        $edgeCount = 0
        while ($edges.Count -gt 0) {
            $enumerator = $edges.GetEnumerator()
            [void]$enumerator.MoveNext()
            $edge = $enumerator.Current
            [void]$edges.Remove($edge)

            $v0 = [Tuple]::Create($edge.Item1, $edge.Item2)
            $v1 = [Tuple]::Create($edge.Item3, $edge.Item4)
            $dx = $v1.Item1 - $v0.Item1
            $dy = $v1.Item2 - $v0.Item2

            # Start with one as we removed one, so it's at least 1 edge long.
            # The rest is just removed
            $edgeCount += 1
            $candidates = [System.Collections.Generic.HashSet[object]]::new()

            [void]$candidates.Add($v0)
            [void]$candidates.Add($v1)

            $removed = 1
            while ($removed -gt 0){
                $removed = 0
                foreach ($edge in $edges) {
                    $v2 = [Tuple]::Create($edge.Item1, $edge.Item2)
                    $v3 = [Tuple]::Create($edge.Item3, $edge.Item4)
                    $dx2 = $v3.Item1 - $v2.Item1
                    $dy2 = $v3.Item2 - $v2.Item2
    
                    # If the edge is connected and have the same direction, remove it
                    # Here, only the same direction is allowed, but to prevent
                    # touches, check if parity is 2 (only two edges are connected)
                    # After testings, seems like parity is way too much. We can skip it,
                    # which makes sense, as we are removing the edges anyway. That means
                    # touches will have different orientation.
                    if (($dx -eq $dx2 -and $dy -eq $dy2)) {
                        if ($candidates.Contains($v2)) {
                            [void]$candidates.Remove($v2)
                            [void]$candidates.Add($v3)
                            [void]$edges.Remove($edge)
                            $removed += 1
                        } elseif ($candidates.Contains($v3)) {
                            [void]$candidates.Remove($v3)
                            [void]$candidates.Add($v2)
                            [void]$edges.Remove($edge)
                            $removed += 1
                        }
                    }
                }
            }
        }

        # Write-Host "Region of $x plants with price $area * $edgeCount = $($area * $edgeCount)"
        $sum += $area * $edgeCount
    }
}

Write-Host $sum
Set-Clipboard $sum