addi $1 $0 3
addi $2 $1 4
add  $3 $1 $2
sw   $3 0($0)
lw   $4 0($0)
add  $5 $4 $1
