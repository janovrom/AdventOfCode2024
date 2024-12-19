$data = Get-Content .\data.txt

function MoveHorizontally($x, $y, $matrix, $dx, $dy) {
    # We move horizontally. That's simplified as we just push everything on the line.
    $newx = $x + $dx
    $newy = $y + $dy

    if ($matrix[$newx][$newy] -eq $global:wall) {
        return $false
    }

    $boxx = $newx
    $boxy = $newy

    while ($matrix[$boxx][$boxy] -eq $global:boxLeft -or $matrix[$boxx][$boxy] -eq $global:boxRight) {
        $boxx += $dx
        $boxy += $dy
    }

    if ($matrix[$boxx][$boxy] -eq $global:wall) {
        return $false
    }

    while ($boxy -ne $y) {
        $matrix[$boxx][$boxy] = $matrix[$boxx - $dx][$boxy - $dy]
        
        $boxx -= $dx
        $boxy -= $dy
    }

    $matrix[$x][$y] = $global:empty

    return $true
}

function MoveBoxesVertically($boxes, $matrix, $dx, $dy) {
    # We move vertically. Now we have to push two things at once.

    # If we can move all the boxes, move them.
    $canMoveAll = $true
    foreach ($box in $boxes) {
        $x = $box.Item1 + $dx
        $yl = $box.Item2 + $dy
        $yr = $box.Item3 + $dy

        if ($matrix[$x][$yl] -eq $global:wall -or $matrix[$x][$yr] -eq $global:wall) {
            # There is a wall, we cannot move at all
            return $false
        }

        if ($matrix[$x][$yl] -ne $global:empty -or $matrix[$x][$yr] -ne $global:empty) {
            $canMoveAll = $false
        }
    }

    if ($canMoveAll -eq $true) {
        foreach ($box in $boxes) {
            $x = $box.Item1 + $dx
            $yl = $box.Item2 + $dy
            $yr = $box.Item3 + $dy

            $matrix[$x][$yl] = $matrix[$box[0]][$box.Item2]
            $matrix[$x][$yr] = $matrix[$box[0]][$box.Item3]
            $matrix[$box[0]][$box.Item2] = $global:empty
            $matrix[$box[0]][$box.Item3] = $global:empty
        }

        return $true
    }

    # If we cannot move all boxes. Check if they are blocked by other boxes.
    # If any box is blocked by a wall, we cannot move the whole stack.
    $newBoxes = [System.Collections.Generic.HashSet[object]]::new()
    foreach ($box in $boxes) {
        $x = $box.Item1 + $dx
        $yl = $box.Item2 + $dy
        $yr = $box.Item3 + $dy

        if ($matrix[$x][$yl] -eq $global:boxLeft) {
            # Left matches left. We move only one box.
            [void]$newBoxes.Add([Tuple]::Create($x, $yl, $yr))
        }
        if ($matrix[$x][$yl] -eq $global:boxRight) {
            # Left matches right. We move both boxes.
            [void]$newBoxes.Add([Tuple]::Create($x, ($yl - 1), $yl))
        }
        
        if ($matrix[$x][$yr] -eq $global:boxLeft) {
            # Right matches left. We move both boxes.
            [void]$newBoxes.Add([Tuple]::Create($x, $yr, ($yr + 1)))
        }
    }

    if ((MoveBoxesVertically $newBoxes $matrix $dx $dy)) {
        # We moved the box dependencies. Now we can move the boxes.
        foreach ($box in $boxes) {
            $x = $box.Item1 + $dx
            $yl = $box.Item2 + $dy
            $yr = $box.Item3 + $dy

            $matrix[$x][$yl] = $matrix[$box[0]][$box.Item2]
            $matrix[$x][$yr] = $matrix[$box[0]][$box.Item3]
            $matrix[$box[0]][$box.Item2] = $global:empty
            $matrix[$box[0]][$box.Item3] = $global:empty
        }

        return $true
    }

    return $false
}

function MoveVertically($x, $y, $matrix, $dx, $dy) {
    # We move vertically. Now we have to push two things at once.
    $newx = $x + $dx
    $newy = $y + $dy

    if ($matrix[$newx][$newy] -eq $global:wall) {
        return $false
    }

    if ($matrix[$newx][$newy] -eq $global:empty) {
        return $true
    }

    if ($matrix[$newx][$newy] -eq $global:boxLeft) {
        return MoveBoxesVertically @([Tuple]::Create($newx, $newy, ($newy + 1))) $matrix $dx $dy
    }

    if ($matrix[$newx][$newy] -eq $global:boxRight) {
        return MoveBoxesVertically @([Tuple]::Create($newx, ($newy - 1), $newy)) $matrix $dx $dy
    }

    return $false
}

function MoveRobot($x, $y, $matrix, $dx, $dy) {
    if ($dx -eq 0) {
        $moved = MoveHorizontally $x $y $matrix $dx $dy
    }
    else {
        $moved = MoveVertically $x $y $matrix $dx $dy
    }

    if ($moved) {
        return ($x + $dx), ($y + $dy)
    }
    else {
        return $x, $y
    }
}

function Draw($matrix, $rx, $ry) {
    $x = 0
    foreach ($row in $matrix) {
        $y = 0
        foreach ($r in $row) {
            if ($rx -eq $x -and $ry -eq $y) {
                Write-Host -NoNewline '@'
                $y += 1
                continue
            }
        
            if ($r -eq $empty) {
                Write-Host -NoNewline '.'
            }
            elseif ($r -eq $wall) {
                Write-Host -NoNewline '#'
            }
            elseif ($r -eq $boxLeft) {
                Write-Host -NoNewline '['
            }
            elseif ($r -eq $boxRight) {
                Write-Host -NoNewline ']'
            }

            $y += 1
        }
        $x += 1
        Write-Host ""
    }
}

$matrix = @()

$i = 0
$rx = 0
$ry = 0
$empty = [int]0
$wall = [int]1
$boxLeft = [int]2
$boxRight = [int]3
for (; $i -lt $data.Length; $i++) {
    $line = $data[$i]

    if ([string]::IsNullOrWhiteSpace($line)) {
        break
    }

    $row = @($empty) * ($line.Length * 2)
    $matrix += , $row

    $j = 0
    foreach ($c in $line.ToCharArray() | % { "$_" }) {
        $j0 = $j * 2
        $j1 = $j0 + 1
        if ($c -eq '.') {
            $row[$j0] = $empty
            $row[$j1] = $empty
        }
        elseif ($c -eq '#') {
            $row[$j0] = $wall
            $row[$j1] = $wall
        }
        elseif ($c -eq 'O') {
            $row[$j0] = $boxLeft
            $row[$j1] = $boxRight
        }
        elseif ($c -eq '@') {
            $rx = $i
            $ry = $j0
            $row[$j] = $empty
        }
        else {
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
        }
        elseif ($instruction -eq 'v') {
            $dx = 1
            $dy = 0
        }
        elseif ($instruction -eq '<') {
            $dx = 0
            $dy = -1
        }
        elseif ($instruction -eq '>') {
            $dx = 0
            $dy = 1
        }

        # We can't move into a wall, but we can push boxes
        $newx = $rx + $dx
        $newy = $ry + $dy

        $rx, $ry = MoveRobot $rx $ry $matrix $dx $dy

        # Draw $matrix $rx $ry
    }
}

Draw $matrix $rx $ry

$x = 0
$sum = 0
foreach ($row in $matrix) {
    $y = 0
    foreach ($r in $row) {
        if ($r -eq $boxLeft) {
            $sum += 100 * $x + $y
        }

        $y += 1
    }
    $x += 1
}

Write-Host $sum
Set-Clipboard $sum