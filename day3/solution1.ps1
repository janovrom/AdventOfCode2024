$data = Get-Content .\data.txt

$memory = $data -join ''

$multiplications = $memory | Select-String -Pattern 'mul\([0-9]{1,3},[0-9]{1,3}\)' -AllMatches

$sum = 0
$multiplications.Matches | ForEach-Object {
    $operands = $_.Value.Replace('mul(', '').Replace(')', '').Split(',')
    $result = [int]$operands[0] * [int]$operands[1]
    $sum += $result
}

Write-Host $sum
Set-Clipboard $sum