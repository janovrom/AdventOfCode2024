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

function Execute($A) {
    $output = @()
    do
    {
        $B = $A % 8 # bst A; store last 3 bits from A to B
        # #B should have 0-7
        $B = $B -bxor 5 # bxl 5; xor B with 0b101
        # Following line removes 0..7 bits from A and stores it in C
        $C = [math]::Floor($A / [math]::pow(2, $B)) # cdv B; bitshift 2 by B and divide A
        $A = [math]::Floor($A / 8) # adv 3; divide A by 8 -> remove last 3 bits used in modulo
        # Till this point, B has only 3 bits.
        # We do some operations and then output the last 3 bits
        $B = $B -bxor $C # bxc C; xor B with C
        $B = $B -bxor 6 # bxl 6; xor B with 0b110
        $output += $B % 8 # out 5; output last 3 bits of B
    } while ($A -ne 0) # jnz 0; goto start, but do at least once

    return $output -join ','
}

function Verify($A) {
    $expected = @(2,4,1,5,7,5,0,3,4,1,1,6,5,5,3,0)
    $idx = 0
    do
    {
        $B = $A % 8 # bst A; store last 3 bits from A to B
        # #B should have 0-7
        $B = $B -bxor 5 # bxl 5; xor B with 0b101
        # Following line removes 0..7 bits from A and stores it in C
        # $C = [math]::Floor($A / [math]::pow(2, $B)) # cdv B; bitshift 2 by B and divide A
        # $A = [math]::Floor($A / 8) # adv 3; divide A by 8 -> remove last 3 bits used in modulo
        $C = $A -shr $B
        $A = $A -shr 3
        # Till this point, B has only 3 bits.
        # We do some operations and then output the last 3 bits
        $B = $B -bxor $C # bxc C; xor B with C
        $B = $B -bxor 6 # bxl 6; xor B with 0b110
        $output = $B % 8 # out 5; output last 3 bits of B

        if ($output -ne $expected[$idx]) {
            return $false
        }

        $idx += 1
    } while ($A -ne 0) # jnz 0; goto start, but do at least once

    return $true
}

# To get 0, B has to be 0
# => 0 = B XOR 6 => B = 6
# => 6 = B XOR C => only last bit has to be the same
# => both odd or both even (i.e. B % 2 = 0/1)

# If B == 5 => C = A => (B = B XOR C): 5 XOR A => B = 5 => (B = B XOR 6): 5 XOR 6 => B = 3
# If B != 5 => C = 

# It's pair of (6,7), (2,3), (4,5),(0,1)
# It has to match bits with last bit different
# 110 - 111, 100 - 101
# 10 - 11
# 0 - 1

# 9 8 7 6 5 4 3 2 1 0
# A A A A A A A B B B
# C C ...
# C C C C C C C C C C

# $output = Execute (3 * 8 + 0) 0 0
# Write-Host $output
# Need 16 outputs. Each cycle we remove 3 bits from A and output one number => we need 48 bits
# xyz
# 101

$expected = "2,4,1,5,7,5,0,3,4,1,1,6,5,5,3,0"

function FindMinimum($A, $i) {
    if (Verify $A) {
        Write-Host $A
        Set-Clipboard $A
        return $A
    }

    for ($x = 0; $x -lt 8; $x+=1) {
        $tested = $A * 8 + $x
        $output = (Execute $tested)
    
        if ($global:expected.EndsWith($output)) {
            # We match the last one, find the rest
            if (FindMinimum $tested ($i + 1) -gt 0) {
                return $tested
            }
        }
    }

    return 0
}

FindMinimum 0 0