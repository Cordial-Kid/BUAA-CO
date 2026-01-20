# dfs is bound to use stack
.data
enter: .asciiz "\n"
space: .asciiz " "
array: .word 0:7
symbol: .word 0:7

.macro getInt(%des)
li $v0 5
syscall
move  %des $v0
.end_macro

.macro printInt(%des)
move $a0 %des
li $v0 1
syscall
.end_macro

.macro printEnter
la $a0 enter
li $v0 4
syscall
.end_macro

.macro printSpace
la $a0 space
li $v0 4
syscall
.end_macro

.macro done
li $v0 10
syscall
.end_macro

.macro push(%des)
addiu $sp $sp -4
sw %des 0($sp)
.end_macro

.macro pop(%des)
lw %des 0($sp)
addiu $sp $sp 4
.end_macro


.text
main:
    getInt($s0)

    li $a0 0
    jal FullArray

    done

FullArray:
    push($ra)
    push($t5)
	push($t0)
	move $t5 $a0
	
    bge $t5 $s0 base_case
    # basecase truly use the $t0 ,but we initial here,so dontneed stack
    # $t0 here need store?
    li $t0 0
    loop_i:      # for(int i=0;i<n;i++)
        beq $t0 $s0 loop_i_end   # i== n ->end
        # symbol[i]
        sll $t1 $t0 2
        lw $t2 symbol($t1)
        bne $t2 $0 if         #if symbol != 0
        # if symbol[i] == 0
        addi $t2 $t0 1
        sll $t3 $t5 2        # cnt array[index]
        sw $t2 array($t3)
        # symbol[i] = 1
        li $t4 1
        sw $t4 symbol($t1)

        # FullArray[index+1]
        addi $t6 $t5 1
        move $a0 $t6       #change a0 related to dfs
        jal FullArray
		# I cannot ensure that $t1 wouldn't change but $t0
		# so just calcalute with $t0
		sll $t1 $t0 2
		sw $0 symbol($t1)
        if:
            addi $t0 $t0 1
            j loop_i
        
    loop_i_end:
    	pop($t0)
        pop($t5)
        pop($ra)
        jr $ra

    base_case:
        jal print
        pop($t0)
        pop($t5)
        pop($ra)
        jr $ra



print:
    li $t0 0
    loop:
        beq $t0 $s0 loop_end
        sll $t3 $t0 2                # when travel array remember sll and dont change index i
        lw $t1 array($t3)
        printInt($t1)
        printSpace
        addi $t0 $t0 1
        j loop

    loop_end:
        printEnter
        jr $ra

