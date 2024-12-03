$data = Get-Content .\data.txt

$memory = $data -join ''

$multiplications = $memory | Select-String -Pattern "mul\([0-9]{1,3},[0-9]{1,3}\)|do\(\)|don't\(\)" -AllMatches

$sum = 0
$mul = 1
$multiplications.Matches | ForEach-Object {
    if ($_.Value -eq 'do()') {
        $mul = 1
    } elseif ($_.Value -eq "don't()") {
        $mul = 0
    } else {
        $operands = $_.Value.Replace('mul(', '').Replace(')', '').Split(',')
        $result = [int]$operands[0] * [int]$operands[1]
        $sum += $mul * $result
    }
}

Write-Host $sum
Set-Clipboard $sum