//fowardA both mem and wb
addi $1 $0 1
add  $2 $1 $0
add  $3 $1 $0


//fowardB both mem and wb
addi $1 $0 5
add  $4 $0 $1
add  $5 $0 $1

//test buble read after load
sw $4 0($0)
lw $6 0($0)
add $7 $6 $2

hlt
