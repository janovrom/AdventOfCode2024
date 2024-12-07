$data = Get-Content .\data.txt

# just add padding to skip the edge cases
$matrix = @()
$matrix += ,(("0" * ($data[0].Length + 2)).ToCharArray() | ForEach-Object { "$_" })

foreach ($line in $data) {
    $matrix += ,(("0$line" + "0").ToCharArray() | ForEach-Object { "$_" })
}

$matrix += ,(("0" * ($data[0].Length + 2)).ToCharArray() | ForEach-Object { "$_" })

$x = 0
$y = 0
$dx = -1
$dy = 0
$sum = 0
$ox = 0
$oy = 0
:outer for ($i = 0; $i -lt $matrix.Length; $i++) {
    $line = $matrix[$i]
    for ($j = 0; $j -lt $line.Length; $j++) {
        if ($line[$j] -eq "^") {
            # We found the big boss, mark it and start navigation
            $x = $i
            $y = $j
            $ox = $i
            $oy = $j
            $matrix[$x][$y] = "."
            break :outer
        }
    }
}

# -1,0 - up
# 1,0 - down
# 0,-1 - left
# 0,1 - right
# if we reach '0' we are out of the matrix
$empty = '.'
$wall = '#'
$end = '0'

$visited = [System.Collections.Generic.HashSet[string]]::new()
while ($matrix[$x][$y] -ne $end) {
    $position = "$x,$y"

    # mark the place and try to move
    if ($matrix[$x][$y] -eq $empty -and $visited.Contains($position) -eq $false) {
        # we were not here before. mark it and add to counter
        [void]$visited.Add($position)
    }

    if ($matrix[$x + $dx][$y + $dy] -eq $wall) {
        # we can't move forward, try to turn right
        $dx, $dy = $dy, -$dx
        continue
    }

    # move forward
    $x += $dx
    $y += $dy
}

$iter = 0
$count = $visited.Count
foreach ($v in $visited) {
    $iter += 1
    Write-Host "`rIteration $iter of $count" -NoNewline
    if ($v -eq "$ox,$oy") {
        # Skip the original position
        continue
    }

    # place obstacle
    $x = $ox
    $y = $oy
    $dx = -1
    $dy = 0
    $set = [System.Collections.Generic.HashSet[string]]::new()
    $tempvisited = [System.Collections.Generic.HashSet[string]]::new()
    [int]$vx, [int]$vy = $v.Split(",")
    $matrix[$vx][$vy] = $wall
    while ($matrix[$x][$y] -ne $end) {
        $state = "$x,$y,$dx,$dy"
        $position = "$x,$y"
        
        if ($set.Contains($state)) {
            # we were here before. we are in a loop
            $sum += 1
            break
        }
        
        [void]$set.Add($state)
        # mark the place and try to move
        if ($matrix[$x][$y] -eq $empty) {
            # we were not here before. mark it and add to counter
            [void]$tempvisited.Add($position)
        }
    
        if ($matrix[$x + $dx][$y + $dy] -eq $wall) {
            # we can't move forward, try to turn right
            $dx, $dy = $dy, -$dx
            continue
        }
    
        # move forward
        $x += $dx
        $y += $dy
    }

    $matrix[$vx][$vy] = $empty
}

Write-Host $sum
Set-Clipboard $sum