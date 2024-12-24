function LoadGraph($data) {
    # Data is a list of edges in format v0-v1
    $edges = @{}
    $vertices = New-Object System.Collections.Generic.HashSet[string]
    foreach ($line in $data) {
        $edge = $line -split '-'
        $v0 = $edge[0]
        $v1 = $edge[1]
        if (-not $edges.ContainsKey($v0)) {
            $edges[$v0] = @()
        }
        if (-not $edges.ContainsKey($v1)) {
            $edges[$v1] = @()
        }
        $edges[$v0] += $v1
        $edges[$v1] += $v0

        if ($v0 -eq $v1) {
            continue
        }
        
        [void]$vertices.Add($v0)
        [void]$vertices.Add($v1)
    }
    
    return [PSCustomObject]@{
        Vertices = $vertices
        Edges = $edges
    }
}

function LoadTestData() {
    $data = Get-Content .\test-data.txt
    return LoadGraph $data
}

function LoadData() {
    $data = Get-Content .\data.txt
    return LoadGraph $data
}