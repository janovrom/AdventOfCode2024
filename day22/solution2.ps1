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

function AddHashed([long]$x, [long]$y) {
    $modulus = 1000 * 1000 * 1000 * 1000
    $slidingWindow = $x * 1000 + ($y + 10)
    $slidingWindow = $slidingWindow % $modulus
    return $slidingWindow
}

function Hash([long]$x, [long]$y, [long]$z, [long]$w) {
    $x = AddHashed 0 $x
    $x = AddHashed $x $y
    $x = AddHashed $x $z
    $x = AddHashed $x $w
    return $x
}

function ReverseHash([long]$hash) {
    $w = $hash % 1000 - 10
    $hash = [math]::Floor($hash / 1000)
    $z = $hash % 1000 - 10
    $hash = [math]::Floor($hash / 1000)
    $y = $hash % 1000 - 10
    $hash = [math]::Floor($hash / 1000)
    $x = $hash % 1000 - 10

    return $x, $y, $z, $w
}

function GetOccurences($number, $iterations) {
    $occurences = @{}
    $result = $number
    $previous = $number % 10
    [long]$slidingWindow = 0
    for ($i = 0; $i -lt $iterations; $i++) {
        $result = Evolve $result

        $change = $result % 10 - $previous
        $slidingWindow = AddHashed $slidingWindow $change

        if ($i -ge 3) {
            # We should have 4 digits in the sliding window
            # We only consider the first occurence as that is when monkey buys the banana
            if (-not $occurences.ContainsKey($slidingWindow)) {
                $occurences[$slidingWindow] = $result % 10
            }
        }

        $previous = $result % 10
    }

    return $occurences
}

function VerifyTestOccurences() {
    # 123: 3 
    # 15887950: 0 (-3)
    # 16495136: 6 (6)
    #   527345: 5 (-1)
    #   704524: 4 (-1)
    #  1553684: 4 (0)
    # 12683156: 6 (2)
    # 11100544: 4 (-2)
    # 12249484: 4 (0)
    #  7753432: 2 (-2)
    $hashes = @(
        (Hash -3 6 -1 -1),
        (Hash 6 -1 -1 0),
        (Hash -1 -1 0 2),
        (Hash -1 0 2 -2),
        (Hash 0 2 -2 0),
        (Hash 2 -2 0 -2)
    )

    $expectedValues = @(
        4, 4, 6, 4, 4, 2
    )

    $occurences = GetOccurences 123 9

    for ($i = 0 ; $i -lt $hashes.Length; $i++) {
        if ($occurences[$hashes[$i]] -ne $expectedValues[$i]) {
            throw "Verification failed: For $($hashes[$i]) $expected $($expectedValues[$i]), but got $($occurences[$hashes[$i]])"
        }
    }
}

VerifyTestOccurences

$data = LoadData

$mostBananalicious = @{}
foreach ($secretNumber in $data.SecretNumbers) {
    $occurences = GetOccurences $secretNumber $data.Iterations
    foreach ($key in $occurences.Keys) {
        if (-not $mostBananalicious.ContainsKey($key)) {
            $mostBananalicious[$key] = $occurences[$key]
        } else {
            $mostBananalicious[$key] += $occurences[$key]
        }
    }
}

# Now we need to get the best occurence
$mostBananalicious = $mostBananalicious.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 1

Write-Host ((ReverseHash $mostBananalicious.Key) -join ',')
Write-Host $mostBananalicious
Set-Clipboard $mostBananalicious.Value