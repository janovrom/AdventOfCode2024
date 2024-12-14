# x is width
# y is height
$data = Get-Content .\data.txt
$width = [int]$data[0].Split(" ")[0]
$height = [int]$data[0].Split(" ")[1]

$robots = 1..($data.Length-1) | ForEach-Object {
    $line = $data[$_]

    $position, $velocity = $line.Split(" ")
    $position = $position.Replace("p=", '')
    $velocity = $velocity.Replace("v=", '')

    $x = [int]$position.Split(",")[0]
    $y = [int]$position.Split(",")[1]

    $vx = [int]$velocity.Split(",")[0]
    $vy = [int]$velocity.Split(",")[1]

    @{x=$x;y=$y;vx=$vx;vy=$vy}
}

$totalSeconds = 100

for ($i = 0; $i -lt $totalSeconds; $i+=1) {
    $robots | ForEach-Object {
        $_.x += $_.vx
        $_.y += $_.vy


        if ($_.x -lt 0) {
            $_.x = $width + $_.x
        }

        if ($_.y -lt 0) {
            $_.y = $height + $_.y
        }

        $_.x = $_.x % $width
        $_.y = $_.y % $height
    }
}

# $robots | ForEach-Object {
#     Write-Output "p=($($_.x),$($_.y)) v=($($_.vx),$($_.vy))"
# }

$middlex = [int][Math]::Floor($width / 2)
$middley = [int][Math]::Floor($height / 2)
$tl = 0
$tr = 0
$bl = 0
$br = 0
$robots | ForEach-Object {
    if ($_.x -lt $middlex) {
        # That means the robot is on the left side
        if ($_.y -lt $middley) {
            # That means the robot is on the top left side
            $tl += 1
        } elseif ($_.y -gt $middley) {
            # That means the robot is on the bottom left side
            $bl += 1
        }
    } elseif ($_.x -gt $middlex) {
        # That means the robot is on the right side
        if ($_.y -lt $middley) {
            # That means the robot is on the top right side
            $tr += 1
        } elseif ($_.y -gt $middley) {
            # That means the robot is on the bottom right side
            $br += 1
        }
    }
}

$mul = $tl * $tr * $bl * $br
Write-Host $mul
Set-Clipboard $mul