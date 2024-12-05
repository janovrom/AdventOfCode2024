$data = Get-Content .\data.txt

$graph = ""
foreach ($line in $data) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        break
    }

    $graph += $line.Replace('|','->') + "`n"
}

Set-Clipboard $graph