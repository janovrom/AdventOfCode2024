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

# Map directions to coordinates
$directions = @{
    $north = [Tuple]::Create(-1, 0)
    $south = [Tuple]::Create(1, 0)
    $west = [Tuple]::Create(0, -1)
    $east = [Tuple]::Create(0, 1)
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

    $nx = $x + $directions[$facing].Item1
    $ny = $y + $directions[$facing].Item2

    if ($maze[$nx][$ny] -eq $wall) {
        # We have to rotate so bump up the cost
        $maze[$x][$y] = $dist + 1000
    }

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

function GetShortestPath($x, $y, $path) {
    if ($x -eq $start.X -and $y -eq $start.Y) {
        [void]$path.Add([Tuple]::Create($x, $y))
        return
    }

    $neighbors = @(
        [Tuple]::Create($x - 1, $y),
        [Tuple]::Create($x + 1, $y),
        [Tuple]::Create($x, $y - 1),
        [Tuple]::Create($x, $y + 1)
    )
    $min = $maze[$x][$y]
    foreach ($n in $neighbors) {
        $nx = $n.Item1
        $ny = $n.Item2
        if ($maze[$nx][$ny] -lt $min -and $maze[$nx][$ny] -ne $global:wall) {
            [void]$path.Add($n)
            GetShortestPath $nx $ny $path
        }
    }
}

# Find the best path by backtracking from end to start by picking the lowest value
$state = [Tuple]::Create($end.X, $end.Y)
$path = [System.Collections.Generic.HashSet[Object]]::new()
[void]$path.Add($state)
GetShortestPath $end.X $end.Y $path

# Print the path
# for ($i = 0; $i -lt $data.Length; $i++) {
#     $row = $data[$i]
#     for ($j = 0; $j -lt $row.Length; $j++) {
#         $c = $row[$j]
#         if ($path.Contains([Tuple]::Create($i, $j))) {
#             Write-Host 'O' -NoNewline
#         } else {
#             Write-Host $c -NoNewline
#         }
#     }
#     Write-Host ''
# }

Write-Host $path.Count
Set-Clipboard $path.Count