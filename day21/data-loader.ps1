function ParseData($data) {
    return [pscustomobject]@{ codes = $data }
}

function LoadData() {
    $data = Get-Content .\data.txt
    return ParseData $data
}

function LoadTestData() {
    $data = Get-Content .\test-data.txt
    return ParseData $data
}