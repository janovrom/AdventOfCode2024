$data = Get-Content .\data.txt
$left = [System.Collections.Generic.List[int]]::new()
$right = [System.Collections.Generic.List[int]]::new()
foreach ($line in $data) {
    $l, $r = $line.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    [void]$left.Add([int]$l)
    [void]$right.Add([int]$r)
}

$left.Sort()
$right.Sort()

$sum = 0
for ($i = 0; $i -lt $left.Count; $i += 1) {
    $diff = $left[$i] - $right[$i]
    $diff = [math]::Abs($diff)
    $sum += $diff
}

Write-Host $sum
Set-Clipboard $sum