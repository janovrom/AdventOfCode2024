$data = Get-Content .\data.txt
$left = [System.Collections.Generic.List[int]]::new()
$right = [System.Collections.Generic.Dictionary[int, int]]::new()
foreach ($line in $data) {
    [int]$l, [int]$r = $line.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    [void]$left.Add($l)

    if ($right.ContainsKey($r)) {
        $right[$r] += 1
    }
    else {
        $right[$r] = 1
    }
}

$sum = 0
for ($i = 0; $i -lt $left.Count; $i += 1) {
    $similarity = $left[$i] * $right[$left[$i]]
    $similarity = [math]::Abs($similarity)
    $sum += $similarity
}

Write-Host $sum
Set-Clipboard $sum