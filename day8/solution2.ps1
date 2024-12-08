$data = Get-Content .\data.txt

$nodes = New-Object System.Collections.Hashtable

$i = 0
foreach ($line in $data) {
    $j = 0
    foreach ($char in $line.ToCharArray()) {
        if ($char -eq '.') {
            $j += 1
            continue
        }

        $key = "$char"

        if (-not $nodes[$key]) {
            $nodes[$key] = @()
        }
        $nodes[$key] += [Tuple]::Create($i, $j)
        $j += 1
    }

    $i += 1
}

$antinodes = [System.Collections.Generic.HashSet[System.Object]]::new()
foreach ($key in $nodes.Keys) {
    $antennas = $nodes[$key]
    foreach ($antenna1 in $antennas) {
        foreach ($antenna2 in $antennas) {
            $dx = $antenna1.Item1 - $antenna2.Item1
            $dy = $antenna1.Item2 - $antenna2.Item2
            $x = $antenna1.Item1
            $y = $antenna1.Item2
            
            if ($antenna1 -eq $antenna2) {
                $new1 = [Tuple]::Create($x, $y)
                [void]$antinodes.Add($new1)
                continue
            }

            while ($true) {
                $x += $dx
                $y += $dy

                if ($x -lt 0 -or $x -ge $data.Length) {
                    break
                }

                if ($y -lt 0 -or $y -ge $data[0].Length) {
                    break
                }

                $new1 = [Tuple]::Create($x, $y)
                [void]$antinodes.Add($new1)
            }
        }
    }
}

$sum = $antinodes.Count

Write-Host $sum
Set-Clipboard $sum