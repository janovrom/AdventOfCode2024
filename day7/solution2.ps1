$data = Get-Content .\data.txt

$sum = 0
Measure-Command {

foreach ($line in $data) {
    $numbers = $line.Split(":", [System.StringSplitOptions]::RemoveEmptyEntries)
    $total = [long]$numbers[0]
    $lengths = $numbers[1].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { $_.Length }
    $numbers = $numbers[1].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { [long]$_ }
    $max = [math]::Pow(3, ($numbers.Length - 1)) # 3 for +,-,||
    for ($i = 0; $i -lt $max; $i++) {
        $bytes = $i
        $solution = $numbers[0]
        for ($j = 1; $j -lt $numbers.Length; $j++) {
            $byte = $bytes % 3
            $bytes = [math]::Floor($bytes / 3)
            if ($byte -eq 0) {
                $solution += $numbers[$j]
            } elseif ($byte -eq 1) {
                $solution *= $numbers[$j]
            } else {
                $next = $numbers[$j]
                $solution = $solution * [math]::Pow(10, $lengths[$j]) + $next
            }
        }

        if ($solution -eq $total) {
            $sum+=$solution
            # Write-Host "Solution for $line : $solution"
            break
        }
    }
}
}

Write-Host $sum
Set-Clipboard $sum