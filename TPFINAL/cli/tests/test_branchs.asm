addi $1 $0 0
addi $2 $0 1
addi $3 $0 0

//should be taken
beq $1 $0 TAKEN1
j FINISH

TAKEN1:
    addi $2 $0 0

addi $1 $0 1
//should be not taken
beq $1 $0 NOTTAKEN
//should be taken
addi $2 $0 1
bne $1 $0 TAKEN2
j FINISH

TAKEN2:
    addi $2 $0 0

addi $1 $0 0
//should be not taken
bne $1 $0 NOTTAKEN

addi $1 $0 1
jal FUNC_JR
addi $1 $0 1
jal FUNC_JALR


addi $31 $0 0
jal FINISH

NOTTAKEN:
    addi $2 $0 1
    jal FINISH


FUNC_JR:
    addi $1 $0 0
    jr $31

FUNC_JALR:
    addi $30 $31 0
    addi $1 $0 0
    jalr $3 $30
    
//code that should not be executed
addi $2 $0 1
addi $3 $0 0

FINISH:
    hlt

