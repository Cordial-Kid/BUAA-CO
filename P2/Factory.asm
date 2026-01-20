.data
space: .asciiz " "

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

# output a str which is a label
.macro printStr(%str)
    la $a0 %str
    li $v0 4
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
    addiiu $sp $sp 4
.end_macro

.text
main:
    getInt($s0)   #s0 is n

    move $a0 $s0
    jal input

    move $a0 $v0
    move $a1 $v1
    jal print

    done

input:
    li $t0 0
    li $t9 0       # t9 to mark the min y
    li $t8 0       # t8 to mark the min x
    li $s6 0
    li $s7 0
    loop_in:
        beq $t0 $a0 loop_in_end
        getInt($t1)    # t1 x
        getInt($t2)    # t2 y
        

        beq $t1 $0 next
        beq $t2 $0 next

        slt $t3 $0 $t1
        slt $t4 $t2 $0
        and $t5 $t3 $t4

        slt $t6 $0 $t2
        slt $t7 $t1 $0
        and $t6 $t6 $t7

        or $t3 $t5 $t6
        beq $t3 $0 next

        bltz $t1 abs_x_neg
        move $s1 $t1
        j abs_x_done

        abs_x_neg:
            sub $s1 $0 $t1

        abs_x_done:
            bltz $t2 abs_y_neg
            move $s2 $t2
            j abs_y_done

        abs_y_neg:
            sub $s2 $0 $t2

        abs_y_done:
            mult $s2 $s1
            mflo $s3        # area_lo
            mfhi $s4        # area_hi

            bgt $s4 $t9 update
            blt $s4 $t9 skip
            bgt $s3 $t8 update
            j skip

            update:
                move $t8 $s3
                move $t9 $s4
                move $s6 $t1   # x
                move $s7 $t2   # y

            skip:
            next:
                addi $t0 $t0 1
                j loop_in
    loop_in_end:
        move $v0 $s6
        move $v1 $s7
        jr $ra

            

print:
    printInt($a0)
    printStr(space)
    printInt($a1)
    jr $ra
