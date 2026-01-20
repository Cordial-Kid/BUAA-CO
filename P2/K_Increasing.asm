.data
arr: .space 80      # int arr[MAX_N] (20 * 4)
subseq: .space 80      # int subseq[MAX_N]
dp: .space 80      # int dp[MAX_N]

# end of program
.macro done
    li $v0 10
    syscall
.end_macro

# read integer and store it in des
.macro getInt(%des)
    li $v0 5
    syscall
    move %des $v0 
.end_macro

# output an integer in src
.macro printInt(%src)
    move $a0 %src
    li $v0 1
    syscall
.end_macro

# push src into the stack
.macro push(%src)
    addiu $sp $sp -4
    sw %src 0($sp)
.end_macro

# pop data from stack and store it in %src
.macro pop(%src)
    lw %src 0($sp)
    addiu $sp $sp 4
.end_macro

# output a str which is a label
.macro printStr(%str)
    la $a0 %str
    li $v0 4
    syscall
.end_macro

.text
main:
    getInt($s0)   # the length of arr
    
    move $a0 $s0
    jal input

    getInt($s1)  # s1 k

    move $a0 $s0  #a0 n
    move $a1 $s1  #a1 k
    jal K_Increasing

	move $a0 $v0
	
    jal print
    done

input:
    li $t0 0
    loop_in:
        beq $t0 $s0 loop_in_end
        getInt($t1)
        sll $t2 $t0 2
        sw $t1 arr($t2)
        addi $t0 $t0 1
        j loop_in
    loop_in_end:
        jr $ra

K_Increasing:
    li $t0 0   # ans = 0
    li $t1 0   # int i =0
    loop_1:
        beq $t1 $s1 loop_1_end
        li $t2 0   # int m = 0
        move $t3 $t1  # j = i
        loop_2:
            bge $t3 $s0 loop_2_end
            sll $t4 $t2 2  # m
            sll $t5 $t3 2  # j
            lw $t5 arr($t5)
            sw $t5 subseq($t4)
            addi $t2 $t2 1
            add $t3 $t3 $s1
            j loop_2
        loop_2_end:
            move $a1 $t2
            push($ra)
            push($t0)
            push($t1)
            push($t2)
            push($t3)
            jal computeLIS
            move $t9 $v0
            pop($t3)
            pop($t2)
            pop($t1)
            pop($t0)
            pop($ra)
            sub $t4 $t2 $t9
            add $t0 $t0 $t4
            addi $t1 $t1 1
            j loop_1
    
    loop_1_end:
        move $v0 $t0 
        jr $ra
            
computeLIS:
    beq $a1 $0 return_zero
    li $t0 1   #maxlen = 1
    
    move $t2, $zero     # i = 0
    init_dp_loop:
    beq $t2, $a1, dp_init_done
    la $t3, dp
    sll $t4, $t2, 2
    add $t3, $t3, $t4
    sw  $t0, 0($t3)     # dp[i] = 1
    addi $t2, $t2, 1
    j init_dp_loop
dp_init_done:

    li $t2 1  # t2 = i
    outer_loop:
        beq $t2 $a1 outer_loop_end
        li $t3 0     # t3 = j
        inner_loop:
            beq $t3 $t2 inner_loop_end
            sll $t4 $t2 2    #i
            sll $t5 $t3 2    #j
            lw $t4 subseq($t4)
            lw $t5 subseq($t5)
            bgt $t5 $t4 skip

            sll $t4 $t2 2    #i
            sll $t5 $t3 2    #j
            lw $t4 dp($t4)
            lw $t5 dp($t5)
            addi $t5 $t5 1

            bgt $t4 $t5 skip
            sll $t4 $t2 2    #i
            sw $t5 dp($t4)

            skip:
                addi $t3 $t3 1
                j inner_loop

        inner_loop_end:
            sll $t4 $t2 2    #i
            lw $t4 dp($t4)
            bgt $t0 $t4 skip_update_maxlen
            move $t0 $t4

            skip_update_maxlen:
                addi $t2 $t2 1
                j outer_loop

    outer_loop_end:
        move $v0 $t0
        jr $ra

    return_zero:
        move $v0 $0
        jr $ra

print:
	printInt($a0)
	jr $ra

