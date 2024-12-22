function LoadTestData() {
    $data = Get-Content .\test-data.txt

    $secretNumbers = $data | ForEach-Object {
        [long]$_
    }

    return [pscustomobject]@{
        SecretNumbers = $secretNumbers
        Iterations = 2000
    }
}

function LoadTestDataPart2() {
    $data = Get-Content .\test-data2.txt

    $secretNumbers = $data | ForEach-Object {
        [long]$_
    }

    return [pscustomobject]@{
        SecretNumbers = $secretNumbers
        Iterations = 2000
    }
}

function LoadData() {
    $data = Get-Content .\data.txt

    $secretNumbers = $data | ForEach-Object {
        [int]$_
    }

    return [pscustomobject]@{
        SecretNumbers = $secretNumbers
        Iterations = 2000
    }
}