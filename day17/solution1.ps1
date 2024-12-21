# combo:
# 0: 0
# 1: 1
# 2: 2
# 3: 3
# 4: A
# 5: B
# 6: C
# 7: reserved (unused)

# instruction 0 adv: A = floor(A / 2^combo)
# instruction 1 bxl: B = B XOR literal
# instruciton 2 bst: B = combo % 8 (keep last 3 bits)
# instruction 3 jnz: if A -ne 0 { goto literal }
# instruction 4 bxc: B = B XOR C
# instruction 5 out: Write-Output (combo % 8)
# instruction 6 bdv: B = floor(A / 2^combo)
# instruction 7 cdv: C = floor(A / 2^combo)

$A = [int]47719761
$B = [int]0
$C = [int]0

$output = @()
do
{
    $B = $A % 8 # bst A; store last 3 bits from A to B
    # #B should have 0-7
    $B = $B -bxor 5 # bxl 5; xor B with 0b101
    $C = [math]::Floor($A / [math]::pow(2, $B)) # cdv B; bitshift 2 by B and divide A
    $A = [math]::Floor($A / 8) # adv 3; divide A by 8 -> remove last 3 bits used in modulo
    $B = $B -bxor $C # bxc C; xor B with C
    $B = $B -bxor 6 # bxl 6; xor B with 0b110
    $output += $B % 8 # out 5; output last 3 bits of B
} while ($A -ne 0) # jnz 0; goto start, but do at least once

$out = $output -join ','
Write-Host $out
Set-Clipboard $out