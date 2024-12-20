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
$path = GetPath $data.end.x $data.end.y $data.maze

Write-Host "Steps required without cheating: $steps [picosecond]"

# Let's start cheating
# Cheating allows to skip wall of thickness 1. So find all such walls and try to bridge
# the values and add 2 (two steps). We can move vertically or horizontally.

$timeSavedCounter = New-Object 'System.Collections.Generic.Dictionary[int, int]'
for ($i = 1; $i -lt $data.maze.Length - 1; $i++) {
    for ($j = 1; $j -lt $data.maze[$i].Length - 1; $j++) {
        if ($data.maze[$i][$j] -eq -1) {
            # We found a wall. Check if we can bridge it
            $up = $data.maze[$i - 1][$j]
            $down = $data.maze[$i + 1][$j]
            $left = $data.maze[$i][$j - 1]
            $right = $data.maze[$i][$j + 1]

            if ($path.Contains([tuple]::Create($i - 1, $j)) -and $path.Contains([tuple]::Create($i + 1, $j))) {
                # We can bridge vertically
                $min = [math]::Min($up, $down)
                $max = [math]::Max($up, $down)
                $stepDiff = $max - $min - 2 # That's what we save

                [void]$timeSavedCounter.TryAdd($stepDiff, 0)
                $timeSavedCounter[$stepDiff] += 1
                # Write-Host "Bridging wall at ($i, $j) vertically. Shaving the time by $stepDiff"
            }
            
            if ($path.Contains([tuple]::Create($i, $j - 1)) -and $path.Contains([tuple]::Create($i, $j + 1))) {
                # We can bridge horizontally
                $min = [math]::Min($left, $right)
                $max = [math]::Max($left, $right)
                
                $stepDiff = $max - $min - 2 # That's what we save
                
                [void]$timeSavedCounter.TryAdd($stepDiff, 0)
                $timeSavedCounter[$stepDiff] += 1
                # Write-Host "Bridging wall at ($i, $j) horizontally. Shaving the time to $stepDiff"
            }
        }
    }
}

# Write-Host "Time saved by cheating:"
# foreach ($key in $timeSavedCounter.Keys | Sort-Object) {
#     Write-Host "  - $($timeSavedCounter[$key]) save $key [picosecond]"
# }

# Get all cheats that shave at least 100 picoseconds
$cheats = $timeSavedCounter.Keys | Where-Object { $_ -ge 100 }

$sum = 0
foreach ($cheat in $cheats) {
    $sum += $timeSavedCounter[$cheat]
}

Write-Host $sum
Set-Clipboard $sum