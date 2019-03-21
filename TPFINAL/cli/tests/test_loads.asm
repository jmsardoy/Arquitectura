addi $1 $0 1
sll  $1 $1 8
addi $1 $1 129
sll  $1 $1 8
addi $1 $1 133
sw $1 0($0)
lbu $2 0($0)
lhu $3 0($0)
lw $4 0($0)
lb $5 0($0)
lh $6 0($0)
hlt
