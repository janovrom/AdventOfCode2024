$data = Get-Content .\data.txt

$sum = 0

foreach ($line in $data) {
    $numbers = $line.Split(":", [System.StringSplitOptions]::RemoveEmptyEntries)
    $total = [long]$numbers[0]
    $numbers = $numbers[1].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { [long]$_ }
    $max = [math]::Pow(2, $numbers.Length - 1)
    for ($i = 0; $i -lt $max; $i++) {
        $bytes = $i
        $solution = $numbers[0]
        for ($j = 1; $j -lt $numbers.Length; $j++) {
            $byte = $bytes % 2
            $bytes = [math]::Floor($bytes / 2)
            if ($byte -eq '0') {
                $solution += $numbers[$j]
            } else {
                $solution *= $numbers[$j]
            }
        }

        if ($solution -eq $total) {
            $sum+=$solution
            # Write-Host "Solution for $line : $solution"
            break
        }
    }
}

Write-Host $sum
Set-Clipboard $sum