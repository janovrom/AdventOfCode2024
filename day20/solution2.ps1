. ".\data-loader.ps1"

$data = LoadData

function FloodFill($startX, $startY, $maze) {
    $queue = [System.Collections.Generic.Queue[object]]::new()
    $queue.Enqueue([tuple]::Create($startX, $startY, 0))

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()
        $x = $current.Item1
        $y = $current.Item2
        $steps = $current.Item3

        if ($maze[$x][$y] -eq -1) {
            continue
        }

        if ($maze[$x][$y] -le $steps) {
            continue
        }

        $maze[$x][$y] = $steps

        $queue.Enqueue([tuple]::Create(($x + 1), $y, ($steps + 1)))
        $queue.Enqueue([tuple]::Create(($x - 1), $y, ($steps + 1)))
        $queue.Enqueue([tuple]::Create($x, ($y + 1), ($steps + 1)))
        $queue.Enqueue([tuple]::Create($x, ($y - 1), ($steps + 1)))
    }
}

function DrawMaze($maze) {
    for ($i = 0; $i -lt $maze.Length; $i++) {
        for ($j = 0; $j -lt $maze[$i].Length; $j++) {
            if ($maze[$i][$j] -eq -1) {
                Write-Host -NoNewline "#`t"
            } elseif ($maze[$i][$j] -eq 999999999) {
                Write-Host -NoNewline ".`t"
            } else {
                Write-Host -NoNewline "$($maze[$i][$j])`t"
            }
        }
        Write-Host ""
    }
    Write-Host ""
}

function GetPath($x, $y, $maze) {
    $path = New-Object System.Collections.Generic.HashSet[object]
    $steps = $maze[$x][$y]

    while ($steps -gt 0) {
        [void]$path.Add([tuple]::Create($x, $y))

        $up = $maze[$x - 1][$y]
        $down = $maze[$x + 1][$y]
        $left = $maze[$x][$y - 1]
        $right = $maze[$x][$y + 1]

        if ($up -eq $steps - 1) {
            $x--
        } elseif ($down -eq $steps - 1) {
            $x++
        } elseif ($left -eq $steps - 1) {
            $y--
        } elseif ($right -eq $steps - 1) {
            $y++
        }

        $steps--
    }

    # We have to add the start point
    [void]$path.Add([tuple]::Create($x, $y))

    return $path
}

FloodFill $data.start.x $data.start.y $data.maze

$steps = $data.maze[$data.end.x][$data.end.y]
$path = GetPath $data.end.x $data.end.y $data.maze | ForEach-Object { ,@($_.Item1, $_.Item2) }

Write-Host "Steps required without cheating: $steps [picosecond]"

# Let's start cheating again.
# This time we get up to (including) 20 picoseconds for free.
# Which means we need for each point on path to find another point on path
# within 20 picoseconds Manahttan distance.

$timeSavedCounter = New-Object 'System.Collections.Generic.Dictionary[int, int]'

$pathLength = $path.Length
for ($i = 0; $i -lt $pathLength; $i++) {
    $p0 = $path[$i]
    for ($j = $i + 1; $j -lt $pathLength; $j++) {
        $p1 = $path[$j]

        $distance = [math]::Abs($p0[0] - $p1[0]) + [math]::Abs($p0[1] - $p1[1])
        if ($distance -le 20) {
            $stepDiff = [math]::Abs($data.maze[$p0[0]][$p0[1]] - $data.maze[$p1[0]][$p1[1]] - $distance)
            if (-not $timeSavedCounter.ContainsKey($stepDiff)) {
                $timeSavedCounter[$stepDiff] = 0
            }
            $timeSavedCounter[$stepDiff] += 1
        }
    }
}

# Get all cheats that shave at least 100 picoseconds
$cheats = $timeSavedCounter.Keys | Where-Object { $_ -ge 100 }

# Write-Host "Time saved by cheating:"
# foreach ($key in $cheats | Sort-Object) {
#     Write-Host "  - $($timeSavedCounter[$key]) save $key [picosecond]"
# }

$sum = 0
foreach ($cheat in $cheats) {
    $sum += $timeSavedCounter[$cheat]
}

Write-Host $sum
Set-Clipboard $sum