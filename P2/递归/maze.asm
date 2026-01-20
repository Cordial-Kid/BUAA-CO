.data
matrix: .space 258
visited: .word 0:64

.macro getInt(%des)
li $v0 5
syscall
move %des $v0
.end_macro

.macro printInt(%des)
move $a0 %des
li $v0 1
syscall
.end_macro

.macro getIndex(%ans,%i,%j,%m)
mul %ans %i %m
add %ans %ans %j
sll %ans %ans 2
.end_macro

.macro push(%des)
addiu $sp $sp -4
sw %des 0($sp)
.end_macro

.macro pop(%des)
lw %des 0($sp)
addiu $sp $sp 4
.end_macro

.macro done
li $v0 10
syscall
.end_macro

.text
main:
	getInt($s0)      # n
	getInt($s1)		 # m
	
	move $a0 $s0
	move $a1 $s1
	jal input
	
	move $a0 $s3
	move $a1 $s4
	move $a2 $s5
	move $a3 $s6
	jal dfs
	
	printInt($t9)
	done
	
input:
	li $t0 0
	loop_in_i:
		beq $t0 $a0 loop_in_i_end
		li $t1 0
		loop_in_j:
			beq $t1 $a1 loop_in_j_end
			getInt($t2)
			getIndex($t3,$t0,$t1,$a1)
			sw $t2 matrix($t3)
			addi $t1 $t1 1
			j loop_in_j
			
		loop_in_j_end:
			addi $t0 $t0 1
			j loop_in_i
			
		loop_in_i_end:
			getInt($s3)  # begin x s3 a0
			addi $s3 $s3 -1
			getInt($s4)  # begin y s4 a1
			addi $s4 $s4 -1
			getInt($s5)  # end x s5 a2
			addi $s5 $s5 -1
			getInt($s6)	 # end y s6 a3
			addi $s6 $s6 -1
			jr $ra
	
dfs:
	# push means reset something
	push($ra)
	push($t0)
	push($t1)
	# cannot push t9 here ????why
	move $t0 $a0
	move $t1 $a1
	
	beq $t0 $a2 if_1
	j else_1
	
	if_1:
		beq $t1 $a3 base_case
		
	else_1:
		# the if judge may be previous
		# the bound
		bge $t0 $s0 illegal
		blt $t0 $0 illegal
		bge $t1 $s1 illegal
		blt $t1 $0 illegal
		# the barrier
		getIndex($t2,$t0,$t1,$s1)
		lw $t3 matrix($t2)
		bne $t3 $0 illegal
		# has visited
		lw $t3 visited($t2)
		beq $t3 $0 legal
		# if bne ,the program will enter illegal definitely,so legal
		illegal:
			li $v0 0
			pop($t1)
			pop($t0)
			pop($ra)
			jr $ra
		
		legal:
			li $t3 1
			getIndex($t4,$t0,$t1,$s1)
			sw $t3 visited($t4)      # visited[i]=1
			li $t9 0         # define t9 = 0
			
			move $a0 $t0
			addi $a0 $a0 1
			move $a1 $t1
			push($t9)
			jal dfs
			pop($t9)
			add $t9 $t9 $v0
			
			move $a0 $t0
			move $a1 $t1
			addi $a0 $a0 -1
			push($t9)
			jal dfs
			pop($t9)
			add $t9 $t9 $v0
			
			move $a0 $t0
			move $a1 $t1
			addi $t1 $t1 1
			push($t9)
			jal dfs
			pop($t9)
			add $t9 $t9 $v0
			
			move $a0 $t0
			move $a1 $t1
			addi $t1 $t1 -1
			push($t9)     # can only push t9 here
			jal dfs
			pop($t9)
			add $t9 $t9 $v0
			
			move $a0 $t0
			move $a1 $t1  # remember to reset
			# this step is key why???
			move $v0 $t9
			
			getIndex($t3,$t0,$t1,$s1)
			li $t4 0
			sw $t4 visited($t3)
			
			pop($t1)
			pop($t0)
			pop($ra)
			jr $ra
	# base_case at last		
	base_case:
		li $v0 1
		pop($t1)
		pop($t0)
		pop($ra)
		jr $ra
			
		
		
		
