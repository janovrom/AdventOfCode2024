. ".\data-loader.ps1"

function TopoSort($gate, $visited, [ref]$sorted) {
    $stack = New-Object 'System.Collections.Generic.Stack[object]'
    $stack.Push($gate)
    while ($stack.Count -gt 0) {
        $current = $stack.Peek()
        if ($visited.Contains($current.Output)) {
            [void]$stack.Pop();
            continue
        }

        $input0Gate = $program.Gates | Where-Object { $_.Output -eq $current.Input0 }
        $input1Gate = $program.Gates | Where-Object { $_.Output -eq $current.Input1 }

        $allVisited = $true
        if ($input0Gate -and -not $visited.Contains($input0Gate.Output)) {
            $stack.Push($input0Gate)
            $allVisited = $false
        }
        if ($input1Gate -and -not $visited.Contains($input1Gate.Output)) {
            $stack.Push($input1Gate)
            $allVisited = $false
        }

        if ($allVisited) {
            $sorted.Value += $current
            [void]$visited.Add($current.Output)
            [void]$stack.Pop()
        }
    }
}

function GetSortedGates($gates) {# We have all the values, now we can topo-sort the gates
    $sorted = @()
    $visited = New-Object 'System.Collections.Generic.HashSet[string]'
    $gates | ForEach-Object {
        TopoSort $_ $visited ([ref]$sorted)
    }

    return $sorted
}

$program = LoadData

$values = New-Object 'System.Collections.Generic.Dictionary[string, int]'
$program.Gates | ForEach-Object {
    [void]$values.Add($_.Output, 0)
}

# Try it with zeros as inputs - we get all zeros
# Try it with ones as inputs - we should get 111 + 111 = 1110 (zero at end)
# We get 1111111111111111111111111111111011111011111110 => z08 and z14 are wrong
# 45 digits + 45 digits = 46 digits
# z08 and z14 are wrong so probably the full adder is wrong (carry-in + xor for sum + and for carry)
$testInputs = @{
    # "x00" = 0
    # "x01" = 1
    # "x02" = 1
    # "x03" = 1
    # "x04" = 1
    # "x05" = 1
    # "x06" = 1
    # "x43" = 1
    "x14" = 1

    # "y00" = 0
    # "y01" = 1
    # "y02" = 1
    # "y03" = 1
    # "y04" = 1
    # "y05" = 1
    # "y06" = 1
    # "y43" = 1
    "y14" = 1
}

# for 14
# 0000000000000000000000000000000100000000000000

# Wrong eval for input 07
# 0000000000000000000000000000000000001011111110
# 8 and 9 bit are swapped

$program.Inputs.Keys | ForEach-Object {
    if ($testInputs.ContainsKey($_)) {
        [void]$values.Add($_, $testInputs[$_])
    } else {
        [void]$values.Add($_, 0)
    }
}

# z23 is or instead of xor
# z23 is or -> should lead to 'bmn'
# xor leading to bmn should be z23

# z18 is and instead of xor
# wss is output of xor, should output to z18

# z08 is and instead of xor
# xor outputing to mvb

# and outputs to rds, but should be xor
# xor outputs to jss, but should be and

# So the wrong pairs are z23 and bmn, z08 and mvb, z18 and wss, rds and jss
# Output them as a ordered list joined by ','
$wrongWires = "z23,bmn,z08,mvb,z18,wss,rds,jss" -split ',' | Sort-Object
$wrongWires = $wrongWires -join ','

Write-Host $wrongWires
Set-Clipboard $wrongWires

# Fix it with the knowledge we have now from graphviz
$z23s = $program.Gates | Where-Object { $_.Output -eq 'z23' }
$bmns = $program.Gates | Where-Object { $_.Output -eq 'bmn' }
$z08s = $program.Gates | Where-Object { $_.Output -eq 'z08' }
$z18s = $program.Gates | Where-Object { $_.Output -eq 'z18' }
$mvbs = $program.Gates | Where-Object { $_.Output -eq 'mvb' }
$wsss = $program.Gates | Where-Object { $_.Output -eq 'wss' }
$rdss = $program.Gates | Where-Object { $_.Output -eq 'rds' }
$jsss = $program.Gates | Where-Object { $_.Output -eq 'jss' }

$z23s | ForEach-Object {
    $_.Output = 'bmn'
}
$bmns | ForEach-Object {
    $_.Output = 'z23'
}
$z08s | ForEach-Object {
    $_.Output = 'mvb'
}
$mvbs | ForEach-Object {
    $_.Output = 'z08'
}
$z18s | ForEach-Object {
    $_.Output = 'wss'
}
$wsss | ForEach-Object {
    $_.Output = 'z18'
}
$rdss | ForEach-Object {
    $_.Output = 'jss'
}
$jsss | ForEach-Object {
    $_.Output = 'rds'
}

# Get graph for graphviz
$graph = "digraph G {"
$program.Gates | ForEach-Object {
    $graph += "$($_.Input0) -> $($_.Output);"
    $graph += "$($_.Input1) -> $($_.Output);"
}

$graph += "node [shape=box]; { rank = same; "
$program.Inputs.Keys | ForEach-Object {
    $graph += "$_;"
}
$graph += "}"

$graph += "node [shape=box]; { rank = same; "
$program.Gates | Where-Object { $_.Output.StartsWith('z')} | ForEach-Object {
    $graph += "$($_.Output);"
}
$graph += "}"

$program.Gates | ForEach-Object {
    $graph += "$($_.Output) [label=`"$($_.Label)`"];"
}

$graph += "}"

# Evaluate the circuit
$sorted = GetSortedGates($program.Gates)

foreach ($gate in $sorted) {
    $a = $values[$gate.Input0]
    $b = $values[$gate.Input1]
    $values[$gate.Output] = $gate.Eval($a, $b)
}

$keys = $values.Keys | Where-Object { $_.StartsWith('z') } | Sort-Object -Descending
$sum = 0
$binaryRepr = ""
$keys | ForEach-Object {
    $sum = $sum * 2 + $values[$_]
    $binaryRepr += $values[$_]
    # Write-Host $_ $values[$_]
}

Write-Host $binaryRepr