$data = Get-Content .\data.txt

$empty = 9999999999
$wall = -2
$maze = @()
$j = 0
foreach ($line in $data) {
    $row = @()
    for ($i = 0; $i -lt $line.Length; $i++) {
        $c = $line[$i]
        if ($c -eq '#') {
            $row += $wall
        } elseif ($c -eq '.') {
            $row += $empty
        } elseif ($c -eq 'S') {
            $row += $empty
            $start = [PSCustomObject]@{ X = $j; Y = $i }
        } elseif ($c -eq 'E') {
            $row += $empty
            $end = [PSCustomObject]@{ X = $j; Y = $i }
        } else {
            throw "Unknown character: $c"
        }
    }
    $j += 1
    $maze += ,$row
}

# Facing:
# > east (default)
# < west
# ^ north
# v south
$east = '>'
$west = '<'
$north = '^'
$south = 'v'

# Create facing map. We can rotate by 0 or 90 degrees for 1000 steps. So east to west costs 2000 steps. Not rotating is 0.
$rotate = @{
    "$east$west" = 2000
    "$west$east" = 2000
    "$north$south" = 2000
    "$south$north" = 2000
    "$east$north" = 1000
    "$east$south" = 1000
    "$west$north" = 1000
    "$west$south" = 1000
    "$north$east" = 1000
    "$north$west" = 1000
    "$south$east" = 1000
    "$south$west" = 1000
    "$east$east" = 0
    "$west$west" = 0
    "$north$north" = 0
    "$south$south" = 0
}



$queue = [System.Collections.Generic.Queue[Object]]::new()
$state = [Tuple]::Create($start.X, $start.Y, 0, $east)
$queue.Enqueue($state)

while ($queue.Count -gt 0) {
    $state = $queue.Dequeue()
    $x = $state.Item1
    $y = $state.Item2
    $dist = $state.Item3
    $facing = $state.Item4

    # Check if we reached the end. Don't stop here, we might find a shorter
    if ($x -eq $end.X -and $y -eq $end.Y) {
        Write-Host "Found end at $dist"
        $maze[$x][$y] = $dist
        continue
    }

    if ($maze[$x][$y] -lt $dist) {
        # We can get there faster, so skip this
        continue
    }

    # We can get there faster using this state
    $maze[$x][$y] = $dist

    $neighbors = @(
        [Tuple]::Create($x - 1, $y, $north),
        [Tuple]::Create($x + 1, $y, $south),
        [Tuple]::Create($x, $y - 1, $west),
        [Tuple]::Create($x, $y + 1, $east)
    )

    foreach ($n in $neighbors) {
        $nx = $n.Item1
        $ny = $n.Item2
        $nfacing = $n.Item3
        # Skip out of bounds check, there are walls around the maze
        # Rotate if needed. But rotation by 90 degrees costs 1000 steps
        $cost = 1 # For the movement
        $cost += $rotate["$facing$nfacing"]


        if ($maze[$nx][$ny] -gt $dist + $cost) {
            $queue.Enqueue([Tuple]::Create($nx, $ny, $dist + $cost, $nfacing))
        }
    }
}

Write-Host $maze[$end.X][$end.Y]
Set-Clipboard $maze[$end.X][$end.Y]