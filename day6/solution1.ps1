$data = Get-Content .\data.txt

# just add padding to skip the edge cases
$matrix = @()
$matrix += ,("0" * ($data[0].Length + 2)).ToCharArray()

foreach ($line in $data) {
    $matrix += ,("0$line" + "0").ToCharArray()
}

$matrix += ,("0" * ($data[0].Length + 2)).ToCharArray()

$x = 0
$y = 0
$dx = -1
$dy = 0
$sum = 0
:outer for ($i = 0; $i -lt $matrix.Length; $i++) {
    $line = $matrix[$i]
    for ($j = 0; $j -lt $line.Length; $j++) {
        if ($line[$j] -eq "^") {
            # We found the big boss, mark it and start navigation
            $x = $i
            $y = $j
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
[char]$empty = '.'
[char]$wall = '#'
[char]$visited = 'x'
[char]$end = '0'
while ($matrix[$x][$y] -ne $end) {
    # mark the place and try to move
    if ($matrix[$x][$y] -eq $empty) {
        # we were not here before. mark it and add to counter
        $sum += 1
        $matrix[$x][$y] = $visited
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

Write-Host $sum
Set-Clipboard $sum