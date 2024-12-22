. ".\data-loader.ps1"

function Evolve($number) {
    $v0 = $number * 64
    $number = $number -bxor $v0
    $number = $number % 16777216

    $v1 = $number -shr 5
    $number = $number -bxor $v1
    $number = $number % 16777216

    $v2 = $number * 2048
    $number = $number -bxor $v2
    $number = $number % 16777216

    return $number
}

function Verify() {
    $secretNumber = 123
    $iterations = 10

    $expectedResults = @(
        15887950,
        16495136,
        527345,
        704524,
        1553684,
        12683156,
        11100544,
        12249484,
        7753432,
        5908254
    )

    $result = $secretNumber
    for ($i = 0; $i -lt $iterations; $i++) {
        $result = Evolve $result
        
        if ($result -ne $expectedResults[$i]) {
            throw "Verification failed: Expected $($expectedResults[$i]), but got $result"
        }
    }
}

function VerifyTestData() {
    $data = LoadTestData

    $expectedResults = @(
        8685429,
        4700978,
        15273692,
        8667524
    )

    $buyer = 0
    foreach ($secretNumber in $data.SecretNumbers) {
        $result = $secretNumber
        for ($i = 0; $i -lt $data.Iterations; $i++) {
            $result = Evolve $result
        }

        if ($result -ne $expectedResults[$buyer]) {
            throw "Verification failed: Expected $($expectedResults[$i]), but got $result"
        }
        $buyer += 1
    }
}

Verify
VerifyTestData

$data = LoadData
$sum = 0
foreach ($secretNumber in $data.SecretNumbers) {
    $result = $secretNumber
    for ($i = 0; $i -lt $data.Iterations; $i++) {
        $result = Evolve $result
    }
    $sum += $result
}

Write-Host $sum
Set-Clipboard $sum