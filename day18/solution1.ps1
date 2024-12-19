$data = Get-Content .\data.txt

# [int]$width = 7
# [int]$height = 7
[int]$width = 71
[int]$height = 71
$max = 99999999

$memory = New-Object 'int[,]' $width, $height
# Fill the memory with big numbers to use for distance checking
for ($i = 0; $i -lt $width; $i+=1) {
    for ($j = 0; $j -lt $height; $j+=1) {
        $memory[$i, $j] = $max
    }
}


# $byteCount = 12 # Will be 1024 for the data
$byteCount = 1024
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
                Write-Host "#" -NoNewline
            } elseif ($memory[$i, $j] -ne $global:max) {
                Write-Host "O" -NoNewline
            } else {
                Write-Host "." -NoNewline
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

FloodFill 0 0 $width $height $memory 0
# DumpMemory $memory $width $height

$steps = $memory[($height-1), ($width-1)]
Write-Host "Steps: $steps"
Set-Clipboard $steps