$data = Get-Content .\data.txt

function MoveRobot($x, $y, $matrix, $dx, $dy) {
    $newx = $x + $dx
    $newy = $y + $dy

    if ($matrix[$newx][$newy] -eq $global:wall) {
        return $false
    }

    if ($matrix[$newx][$newy] -eq $global:box) {
        $boxMoved = MoveRobot $newx $newy $matrix $dx $dy

        if ($boxMoved -eq $false) {
            return $false
        }
    }

    $matrix[$newx][$newy] = $matrix[$x][$y]
    $matrix[$x][$y] = $global:empty

    return $true
}

$matrix = @()

$i = 0
$rx = 0
$ry = 0
$empty = [int]0
$wall = [int]1
$box = [int]2
for (;$i -lt $data.Length; $i++) {
    $line = $data[$i]

    if ([string]::IsNullOrWhiteSpace($line)) {
        break
    }

    $row = @($empty) * $line.Length
    $matrix += ,$row

    $j = 0
    foreach($c in $line.ToCharArray() | % { "$_" }) {
        if ($c -eq '.') {
            $row[$j] = $empty
        } elseif ($c -eq '#') {
            $row[$j] = $wall
        } elseif ($c -eq 'O') {
            $row[$j] = $box
        } elseif ($c -eq '@') {
            $rx = $i
            $ry = $j
            $row[$j] = $empty
        } else {
            exit("Invalid character: $c")
        }
        $j += 1
    }
}

$dx = 0
$dy = 0
$i += 1
for (; $i -lt $data.Length; $i++) {
    $line = $data[$i]

    if ([string]::IsNullOrWhiteSpace($line)) {
        break
    }

    $instructions = $line.ToCharArray()

    foreach ($instruction in $instructions) {
        # ^ up
        # v down
        # < left
        # > right
        if ($instruction -eq '^') {
            $dx = -1
            $dy = 0
        } elseif ($instruction -eq 'v') {
            $dx = 1
            $dy = 0
        } elseif ($instruction -eq '<') {
            $dx = 0
            $dy = -1
        } elseif ($instruction -eq '>') {
            $dx = 0
            $dy = 1
        }

        # We can't move into a wall, but we can push boxes
        $newx = $rx + $dx
        $newy = $ry + $dy

        if ((MoveRobot $rx $ry $matrix $dx $dy) -eq $true) {
            $rx = $newx
            $ry = $newy
        }

        # Write-Host "****************************"
        # Write-Host "Move $instruction to $rx $ry"
        # $x = 0
        # foreach ($row in $matrix) {
        #     $y = 0
        #     foreach ($r in $row) {
        #         if ($rx -eq $x -and $ry -eq $y) {
        #             Write-Host -NoNewline '@'
        #             $y += 1
        #             continue
        #         }
                
        #         if ($r -eq $empty) {
        #             Write-Host -NoNewline '.'
        #         } elseif ($r -eq $wall) {
        #             Write-Host -NoNewline '#'
        #         } elseif ($r -eq $box) {
        #             Write-Host -NoNewline 'O'
        #         }

        #         $y += 1
        #     }
        #     $x += 1
        #     Write-Host ""
        # }
        # Write-Host "****************************"
    }
}


# $x = 0
# foreach ($row in $matrix) {
#     $y = 0
#     foreach ($r in $row) {
#         if ($rx -eq $x -and $ry -eq $y) {
#             Write-Host -NoNewline '@'
#             $y += 1
#             continue
#         }
        
#         if ($r -eq $empty) {
#             Write-Host -NoNewline '.'
#         } elseif ($r -eq $wall) {
#             Write-Host -NoNewline '#'
#         } elseif ($r -eq $box) {
#             Write-Host -NoNewline 'O'
#         }

#         $y += 1
#     }
#     $x += 1
#     Write-Host ""
# }

$x = 0
$sum = 0
foreach ($row in $matrix) {
    $y = 0
    foreach ($r in $row) {
        if ($r -eq $box) {
            $sum += 100 * $x + $y
        }

        $y += 1
    }
    $x += 1
}

Write-Host $sum
Set-Clipboard $sum