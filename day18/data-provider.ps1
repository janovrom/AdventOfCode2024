function LoadData {
    $data = Get-Content .\data.txt
    [int]$width = 71
    [int]$height = 71

    return $data, $width, $height, 1024
}

function LoadTestData {
    $data = Get-Content .\test-data.txt
    [int]$width = 7
    [int]$height = 7

    return $data, $width, $height, 12
}