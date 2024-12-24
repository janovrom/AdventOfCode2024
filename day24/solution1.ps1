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
$program.Inputs.Keys | ForEach-Object {
    [void]$values.Add($_, $program.Inputs[$_])
}

$sorted = GetSortedGates($program.Gates)

foreach ($gate in $sorted) {
    $a = $values[$gate.Input0]
    $b = $values[$gate.Input1]
    $values[$gate.Output] = $gate.Eval($a, $b)
}

$keys = $values.Keys | Where-Object { $_.StartsWith('z') } | Sort-Object -Descending
$sum = 0
$keys | ForEach-Object {
    $sum = $sum * 2 + $values[$_]
    # Write-Host $_ $values[$_]
}

Write-Host $sum
Set-Clipboard $sum