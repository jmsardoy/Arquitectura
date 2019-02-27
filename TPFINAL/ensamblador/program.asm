//load array from 0 to 9 in data memory
// register $1 is used as counter for loop
// register $2 is used as and aux variable
// register $3 is used to hold data memory address

addi $1 $0 10
addi $2 $0 0
addi $3 $0 0

LOAD_FOR:
    sw   $2 0($3)       //store data in $3
    addi $2 $2 1       //increment variable by 10
    addi $3 $3 1        //increment data memory address
    addi $1 $1 -1       //decrement counter
    bne  $1 $0 LOAD_FOR


addi $1 $0 10
addi $3 $0 0
FOR_LOOP:
    lw   $2 0($3)       //load data from array
    jal  SUM_1_MULT_2   //call rutine SUM_1_MULT_2
    sw   $2 0($3)       //store result
    addi $1 $1 -1       //decrement counter
    addi $3 $3 1        //increment data memory address
    bne  $1 $0 FOR_LOOP

addi $4 $0 156

lw $5 0($0)
lw $6 1($0)
lw $7 2($0)
lw $8 3($0)
lw $9 4($0)
lw $10 5($0)
lw $11 6($0)
lw $12 7($0)
lw $13 8($0)
j FINISH


// rutine
// adds 1 and multiplies by 2 register $2
// and then makes it negative
SUM_1_MULT_2:
    addi $2 $2 1        //add 1
    sll  $2 $2 1        //multiply by 2
    sll  $4 $2 1        //multiply $2 by 2 and store it in $4
    sub  $2 $2 $4       //substract $4 to $2 and store it in $2
    jr   $31            //jump to return address


FINISH:
    hlt
