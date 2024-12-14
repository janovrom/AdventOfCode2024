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

$totalSeconds = 10000
$saveFrom = 1000

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

    if ($i -lt $saveFrom) {
        continue
    }

    # We need to notice that every 101 frames, there is a pattern. 
    # And the same goes for 103. These get closer together and
    # when they meet, we have the solution.
    [System.Drawing.Bitmap]$bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $robots | ForEach-Object {
        $bitmap.SetPixel($_.x, $_.y, [System.Drawing.Color]::FromArgb(255, 255, 255, 255))
    }
    $bitmap.Save("frames\frame$i.png")
}