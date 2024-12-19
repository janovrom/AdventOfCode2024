Import-Module .\data-provider.ps1

$data, $width, $height, $byteCount = LoadData

$max = 99999999

$memory = New-Object 'int[,]' $width, $height
# Fill the memory with big numbers to use for distance checking
for ($i = 0; $i -lt $width; $i+=1) {
    for ($j = 0; $j -lt $height; $j+=1) {
        $memory[$i, $j] = $max
    }
}


for ($i = 0; $i -lt $byteCount; $i+=1) {
    $byte = $data[$i]
    # x left
    # y top
    $x, $y = $byte.Split(',') | ForEach-Object { [int]$_ }
    $memory[$y, $x] = -1
}

function DumpMemory($memory, $width, $height) {
    for ($i = 0; $i -lt $width; $i+=1) {
        for ($j = 0; $j -lt $height; $j+=1) {
            if ($memory[$i, $j] -eq -1) {
                Write-Host "#`t" -NoNewline
            } elseif ($memory[$i, $j] -ne $global:max) {
                Write-Host "$($memory[$i,$j])`t" -NoNewline
            } else {
                Write-Host ".`t" -NoNewline
            }
        }
        Write-Host ""
    }
}

function FloodFill($x, $y, $width, $height, $memory, $steps) {
    $queue = [System.Collections.Queue]::new()
    $queue.Enqueue([tuple]::Create($x, $y, $steps))

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()
        $cx, $cy, $csteps = $current.Item1, $current.Item2, $current.Item3

        if ($cx -lt 0 -or $cx -ge $width -or $cy -lt 0 -or $cy -ge $height) {
            continue
        }

        # Don't enter corrupted memory
        if ($memory[$cy, $cx] -eq -1) {
            continue
        }

        # Don't enter lower or equal cost
        if ($memory[$cy, $cx] -le $csteps) {
            continue
        }

        $memory[$cy, $cx] = $csteps

        $queue.Enqueue([tuple]::Create($cx+1, $cy, $csteps + 1))
        $queue.Enqueue([tuple]::Create($cx-1, $cy, $csteps + 1))
        $queue.Enqueue([tuple]::Create($cx, $cy+1, $csteps + 1))
        $queue.Enqueue([tuple]::Create($cx, $cy-1, $csteps + 1))
    }
}

function GetPathMemoryFootprint($memory, $width, $height) {
    $footprint = [System.Collections.Generic.HashSet[object]]::new()
    $steps = $memory[($height-1), ($width-1)]
    [int]$x = $width - 1
    [int]$y = $height - 1
    # While we didn't reach the start, find the path by backtracking
    while ($steps -gt 0) {
        $steps -= 1
        if ($x -gt 0 -and $memory[$y, ($x-1)] -eq $steps) {
            $x -= 1
        } elseif ($x -lt ($width-1) -and $memory[$y, ($x+1)] -eq $steps) {
            $x += 1
        } elseif ($y -gt 0 -and $memory[($y-1), $x] -eq $steps) {
            $y -= 1
        } elseif ($y -lt ($height-1) -and $memory[($y+1), $x] -eq $steps) {
            $y += 1
        }

        $t = [tuple]::Create($x, $y)
        [void]$footprint.Add($t)
    }

    return $footprint
}

FloodFill 0 0 $width $height $memory 0
# DumpMemory $memory $width $height

$steps = $memory[($height-1), ($width-1)]
$footprint = GetPathMemoryFootprint $memory $width $height

# Simulate rest of the memory blocks
for ($i = $byteCount; $i -lt $data.Length; $i+=1) {
    $byte = $data[$i]
    # x left
    # y top
    $x, $y = $byte.Split(',') | ForEach-Object { [int]$_ }
    $memory[$y, $x] = -1

    # Definitely not on the path
    if ($memory[$y, $x] -gt $steps) {
        continue
    }

    if ($footprint.Contains([tuple]::Create($x, $y))) {
        # This might be a blocking memory block
        # Verify by resetting the memory and re-flood fill
        for ($j = 0; $j -lt $width; $j+=1) {
            for ($k = 0; $k -lt $height; $k+=1) {
                if ($memory[$j, $k] -eq -1) {
                    continue
                }
                $memory[$j, $k] = $max
            }
        }
        FloodFill 0 0 $width $height $memory 0
        $steps = $memory[($height-1), ($width-1)]
        if ($steps -eq $max) {
            Write-Host "Memory block at ($x, $y) is blocking the path"
            Set-Clipboard "$x,$y"
            break
        }

        $footprint = GetPathMemoryFootprint $memory $width $height
    }
}