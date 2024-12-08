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
            if ($antenna1 -eq $antenna2) {
                continue
            }

            $dx = $antenna1.Item1 - $antenna2.Item1
            $dy = $antenna1.Item2 - $antenna2.Item2

            $new1 = [Tuple]::Create($antenna1.Item1 + $dx, $antenna1.Item2 + $dy)
            
            [void]$antinodes.Add($new1)
        }
    }
}

# for ($i = 0; $i -lt $data.Length; $i+=1) {
#     for ($j = 0; $j -lt $data[$i].Length; $j+=1) {
#         $antenna = [Tuple]::Create($i, $j)
#         if ($antinodes.Contains($antenna)) {
#             Write-Host -NoNewline "#"
#         } else {
#             Write-Host -NoNewline $data[$i][$j]
#         }
#     }

#     Write-Host ""
# }

$sum = 0
foreach ($antinode in $antinodes) {
    if ($antinode.Item1 -lt 0 -or $antinode.Item1 -ge $data.Length) {
        continue
    }

    if ($antinode.Item2 -lt 0 -or $antinode.Item2 -ge $data[0].Length) {
        continue
    }

    $sum += 1
}

Write-Host $sum
Set-Clipboard $sum