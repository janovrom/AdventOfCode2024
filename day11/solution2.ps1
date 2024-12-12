$data = Get-Content .\data.txt

$stones = $data.Split(' ') | ForEach-Object { [long]$_ }
# $totalBlinks = 25 # solution1
$totalBlinks = 75 # solution2

function GetLength($number) {
    $length = 0
    while ($number -ne 0) {
        $d = $number / 10
        $number = [math]::Floor($d)
        $length += 1
    }
    return $length
}

function SumChildren($stone, $blinks, $counter) {
    $sum = 0
    
    if ($blinks -ge $global:totalBlinks) {
        # We reached the end
        $counter[$blinks][$stone] = 1
        return 1;
    }

    if ($counter[$blinks].ContainsKey($stone)) {
        return $counter[$blinks][$stone]
    }

    $next = $blinks + 1

    $len = GetLength $stone
    # If the stone is 0, make it 1
    if ($stone -eq 0) {
        $sum += SumChildren 1 $next $counter
    } elseif ($len % 2 -eq 0) {
        $half = $len / 2
        $left = [math]::Floor(($stone / [math]::Pow(10, $half)))
        $right = $stone % [math]::Pow(10, $half)
        
        $sum += SumChildren $left $next $counter
        $sum += SumChildren $right $next $counter
    } else {
        $sum += SumChildren ($stone * 2024) $next $counter
    }

    # We need to cache the results
    $counter[$blinks][$stone] = $sum

    return $sum
}


[long]$sum = 0
$counter = @()

0..$totalBlinks | ForEach-Object {
    $counter += [System.Collections.Generic.Dictionary[Long,long]]::new()
}

foreach ($stone in $stones) {
    Write-Host "Processing $stone"
    $sum += SumChildren $stone 0 $counter
}

Write-Host $sum
Set-Clipboard $sum