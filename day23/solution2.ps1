. ".\data-loader.ps1"

# For this part we need to find the largest clique in the graph.
# We then sort the vertices alphabetically and join them using a hyphen.
# That's a password to join the largest LAN party.

function GetCliques($graph) {
    $cliques = New-Object 'System.Collections.Generic.HashSet[string]'
    $vertices = $graph.Vertices
    $edges = $graph.Edges

    function GetCandidate($clique) {
        foreach ($v in $clique) {
            # Find first neightbor that is not in the clique
            foreach ($neighbor in $edges[$v]) {
                if ($clique.Contains($neighbor)) {
                    continue
                }

                # Verify that all vertices in the clique are connected to the neighbor
                $connected = $true
                foreach ($c in $clique) {
                    if (-not $edges[$neighbor].Contains($c)) {
                        $connected = $false
                        break
                    }
                }

                if ($connected) {
                    return $neighbor
                }
            }
        }

        return $null
    }

    function ExtendClique($clique) {
        $candidate = GetCandidate $clique
        
        $maxClique = $clique

        while ($null -ne $candidate) {
            [void]$clique.Add($candidate)
            $candidate = GetCandidate $clique
            if ($clique.Count -gt $maxClique.Count) {
                $maxClique = $clique
            }
        }

        return $maxClique
    }

    foreach ($v in $vertices) {
        $clique = New-Object 'System.Collections.Generic.HashSet[string]'
        [void]$clique.Add($v)
        $clique = ExtendClique $clique
        [void]$cliques.Add(($clique | Sort-Object) -join ',')
    }

    return $cliques
}

$graph = LoadData
$cliques = GetCliques $graph
$password = $cliques | Sort-Object { - $_.Length } | Select-Object -First 1

Write-Host $password
Set-Clipboard $password