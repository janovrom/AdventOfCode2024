function ParseData($data, $depth) {
    return [pscustomobject]@{
        codes = $data
        searchDepth = $depth 
    }
}

function LoadData() {
    $data = Get-Content .\data.txt
    return ParseData $data 3
}

function LoadDataPart2() {
    $data = Get-Content .\data.txt
    return ParseData $data 26
}

function LoadTestData() {
    $data = Get-Content .\test-data.txt
    return ParseData $data 3
}