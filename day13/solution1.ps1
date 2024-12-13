$data = Get-Content .\data.txt

$tokensRequired = 0
for ($i = 0; $i -lt $data.Length; $i+=4) {
    $A = $data[$i].Split(': ')[1].Replace('X+', '').Replace('Y+', '').Split(', ') | ForEach-Object { [int]$_ }
    $B = $data[$i+1].Split(': ')[1].Replace('X+', '').Replace('Y+', '').Split(', ') | ForEach-Object { [int]$_ }
    $prize = $data[$i+2].Split(': ')[1].Replace('X=', '').Replace('Y=', '').Split(', ') | ForEach-Object { [int]$_ }

    # To get the prize, we need to solve following equation:
    # prize = A * x + B * y => prize = [A B] * [x y]
    # x + y <= 100
    # Px = Ax * x + Bx * y
    # Py = Ay * x + By * y
    # 
    # -Bx * Py / By = -Bx * Ay / By * x - Bx * y
    # Px - Bx * Py / By = Ax * x + Bx * y - Bx * Ay / By * x - Bx * y
    # Px - Bx * Py / By = Ax * x - Bx * Ay / By * x
    # Px - Bx * Py / By = (Ax - Bx * Ay / By) * x
    # x = (Px - Bx * Py / By) / (Ax - Bx * Ay / By)

    $x = ($prize[0] - $B[0] * $prize[1] / $B[1]) / ($A[0] - $B[0] * $A[1] / $B[1])
    $y = ($prize[1] - $A[1] * $x) / $B[1]

    
    # Convert x and y to integers if they are very close to integers
    if ($x % 1 -lt 0.0001) {
        $x = [int][math]::Floor($x)
    }
    if ($y % 1 -lt 0.0001) {
        $y = [int][math]::Floor($y)
    }
    if ($x % 1 -gt 0.9999) {
        $x = [int][math]::Ceiling($x)
    }
    if ($y % 1 -gt 0.9999) {
        $y = [int][math]::Ceiling($y)
    }

    if ($x % 1 -ne 0 -or $y % 1 -ne 0) {
        Write-Host "Inorrect solution has roots x: $x, y: $y"
        continue
    }
    
    if ($x -lt 0 -or $y -lt 0) {
        continue
    }
    
    if ($x -le 100 -and $y -le 100) {
        $tokensRequired += 3 * $x + 1 * $y
    }
}

Write-Host $tokensRequired
Set-Clipboard $tokensRequired