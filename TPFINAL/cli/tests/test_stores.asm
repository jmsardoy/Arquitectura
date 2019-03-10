addi $1 $0 1
sll  $1 $1 8
addi $1 $1 1
sll  $1 $1 8
addi $1 $1 5
sw $1 0($0)
sh $1 1($0)
sb $1 2($0)
hlt
