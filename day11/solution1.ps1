$data = Get-Content .\data.txt

$stones = $data.Split(' ') | ForEach-Object { [long]$_ }

# $totalBlinks = 25 # solution1
$totalBlinks = 25 # solution2
[long]$sum = 0
Measure-Command {
$results = $stones | ForEach-Object  -ThrottleLimit 8 -Parallel {
    function GetLength($number) {
        $length = 0
        while ($number -ne 0) {
            $d = $number / 10
            $number = [math]::Floor($d)
            $length += 1
        }
        return $length
    }

    $stone = $PSItem
    Write-Host "Processing $stone"
    $sum = 0
    $queue = [System.Collections.Queue]::new()
    [void]$queue.Enqueue(($stone, 0))

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()

        # Skip if we did all the blinks needed
        if ($current[1] -ge $using:totalBlinks) {
            $sum += 1
            # Write-Host "$($current[0]), " -NoNewline
            continue
        }

        $next = $current[1] + 1

        # If the stone is 0, make it 1
        if ($current[0] -eq 0) {
            $queue.Enqueue((1, $next))
            continue
        }

        # If the stone has even number of digits, split it in half

        $len = global:GetLength $current[0]
        if ($len % 2 -eq 0) {
            $half = $len / 2
            $left = [math]::Floor(($current[0] / [math]::Pow(10, $half)))
            $right = $current[0] % [math]::Pow(10, $half)
            $queue.Enqueue(($left, $next))
            $queue.Enqueue(($right, $next))
            continue
        }

        # Engrave the stone with multiple of 2024
        $queue.Enqueue((($current[0] * 2024), $next))
    }

    $sum
}

foreach ($r in $results) {
    $sum += $r
}

Write-Host $sum
Set-Clipboard $sum
}