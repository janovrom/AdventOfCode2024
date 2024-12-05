$data = Get-Content .\data.txt

$width = $data[0].Length
$height = $data.Length

$w = 0
$h = 0

function Evaluate([int]$dx, [int]$dy, [int]$w, [int]$h, [int]$width, [int]$height) {
    $x = $w
    $y = $h
    $char = '0'
    while ($x -ne $w + 4 * $dx -or $y -ne $h + 4 * $dy) {
        if ($x -lt 0 -or $x -ge $width) {
            return 0
        }
    
        if ($y -lt 0 -or $y -ge $height) {
            return 0
        }

        $next = $data[$y][$x]

        if (-not (FollowsUp $char $next)) {
            return 0;
        }

        $char = $next
        $x += $dx
        $y += $dy
    }

    return 1
}

$sum = 0
foreach ($line in $data) {
    $w = 0
    foreach ($char in $line.ToCharArray()) {
        if ($char -eq "X") {
            $sum += Evaluate 1 0 $w $h $width $height
            $sum += Evaluate 0 1 $w $h $width $height
            $sum += Evaluate -1 0 $w $h $width $height
            $sum += Evaluate 0 -1 $w $h $width $height
            $sum += Evaluate 1 1 $w $h $width $height
            $sum += Evaluate 1 -1 $w $h $width $height
            $sum += Evaluate -1 1 $w $h $width $height
            $sum += Evaluate -1 -1 $w $h $width $height
        }
        $w += 1
    }
    $h += 1
}

function FollowsUp($char, $followUp) {
    if ($char -eq '0' -and $followUp -eq 'X') {
        return $true;
    } elseif ($char -eq 'X' -and $followUp -eq 'M') {
        return $true;
    } elseif ($char -eq 'M' -and $followUp -eq 'A') {
        return $true;
    } elseif ($char -eq 'A' -and $followUp -eq 'S') {
        return $true;
    }

    return $false;
}

Write-Host $sum
Set-Clipboard $sum