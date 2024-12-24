. ".\data-loader.ps1"

function FindTriangles($graph) {
    $triangles = New-Object System.Collections.Generic.HashSet[string]
    foreach ($v0 in $graph.Vertices) {
        foreach ($v1 in $graph.Edges[$v0]) {
            foreach ($v2 in $graph.Edges[$v1]) {
                if ($v2 -ne $v0 -and $graph.Edges[$v2] -contains $v0) {
                    $triangle = [string[]]@($v0, $v1, $v2)
                    [Array]::Sort($triangle)
                    [void]$triangles.Add([string]::Join('-', $triangle))
                }
            }
        }
    }
    return $triangles
}

$graph = LoadData
$triangles = FindTriangles $graph
$uniqueTriangles = $triangles | Sort-Object -Unique
$sum = 0

foreach ($triangle in $uniqueTriangles) {
    if ($triangle[0] -eq 't' -or $triangle[3] -eq 't' -or $triangle[6] -eq 't') {
        $sum += 1
        # Write-Host "Found $triangle"
    }
}

Write-Host $sum
Set-Clipboard $sum