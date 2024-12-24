function LoadTestData() {
    $data = Get-Content .\test-data.txt

    return ParseData $data
}

function LoadData() {
    $data = Get-Content .\data.txt

    return ParseData $data
}

function ParseData($data) {
    $inputs = @{}
    $gates = @()

    $xor = 'XOR'
    $and = 'AND'
    $or = 'OR'

    $loadinputs = $true
    foreach ($line in $data) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            $loadinputs = $false
            continue
        }

        if ($loadinputs) {
            $key, $value = $line -split ': '
            $inputs[$key] = [int]$value
        } else {
            $line = $line -replace '-> ',''
            $i0, $g, $i1, $out = $line -split ' '
            
            $gate = [PSCustomObject]@{
                input0 = $i0
                Input1 = $i1
                Output = $out
                Label = $g
            }

            if ($g -eq $xor) {
                $gate | Add-Member -MemberType ScriptMethod -Name Eval -Value $function:Xor
            } elseif ($g -eq $and) {
                $gate | Add-Member -MemberType ScriptMethod -Name Eval -Value $function:And
            } elseif ($g -eq $or) {
                $gate | Add-Member -MemberType ScriptMethod -Name Eval -Value $function:Or
            }

            $gates += $gate
        }
    }

    return [PSCustomObject]@{
        Inputs = $inputs
        Gates = $gates
    }
}

function Xor() {
    param($a, $b)
    return $a -bxor $b
}

function And() {
    param($a, $b)
    return $a -band $b
}

function Or() {
    param($a, $b)
    return $a -bor $b
}