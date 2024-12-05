$data = Get-Content .\data.txt

$width = $data[0].Length
$height = $data.Length

$w = 0
$h = 0

# ms|mm|sm|ss
# ms|ss|sm|mm
# msms|mmss|smsm|ssmm

function Evaluate($data, [int]$w, [int]$h) {
    $middle = $data[$h][$w]

    if ($middle -ne 'A') {
        return 0
    }

    $tl = $data[$h - 1][$w - 1]
    $tr = $data[$h - 1][$w + 1]
    $bl = $data[$h + 1][$w - 1]
    $br = $data[$h + 1][$w + 1]

    $str = $tl + $tr + $bl + $br

    if ($str -eq 'MSMS' -or $str -eq 'MMSS' -or $str -eq 'SMSM' -or $str -eq 'SSMM') {
        return 1;
    }

    return 0
}

$sum = 0

for ($h = 1; $h -lt $height - 1; $h += 1) {
    for ($w = 1; $w -lt $width - 1; $w += 1) {
        $sum += Evaluate $data $w $h
    }
}

Write-Host $sum
Set-Clipboard $sum