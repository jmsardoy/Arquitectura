//load array from 0 to 9 in data memory
addi $1 $0 10
addi $2 $0 0
addi $3 $0 0

LOAD_FOR:
    sw   $2 0($3)
    addi $2 $2 10
    addi $3 $3 1
    addi $1 $1 -1
    bne  $1 $0 LOAD_FOR

//adding 1 to each value of array
addi $1 $0 10
addi $3 $0 0

SUM_1_FOR:
    lw   $2 0($3)
    jal  SUM_1
    sw   $2 0($3)
    addi $1 $1 -1
    addi $3 $3 1
    bne  $1 $0 SUM_1_FOR

j FINISH

SUM_1:
    addi $2 $2 1
    jr   $31

FINISH:
