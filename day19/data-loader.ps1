function LoadTestData() {
    $data = Get-Content .\test-data.txt

    return ParseData $data
}

function LoadData() {
    $data = Get-Content .\data.txt

    return ParseData $data
}

function ParseData($data) {
    $patterns = $data[0].Split(', ')

    $arrangements = @()
    for ($i = 2; $i -lt $data.Length; $i++) {
        $arrangements += $data[$i]
    }
    
    return @{
        patterns = $patterns
        arrangements = $arrangements
    }
}