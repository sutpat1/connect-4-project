  .data
    increment: .word 1
    .globl startingMoves cpuTurnEnd
      
   .text
    #Starting moves begin in center and tries to control as much of center as possible
   startingMoves:
   addi $sp, $sp, -8   
   sw $ra, 0($sp) 
   sw $s0, 4($sp)  
     
        lw $s0, increment #increment for moves
        startingPoint:
        li $t3, 1
        beq $s0, $t3, move1
        jal checkForWin
        jal computerMove
        jal checkForWin
    cpuTurnEnd:
        
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra
       
       move1:
    	li $a0, 3
    	li $a1, 5
    	li $a2, 2
    	
    	move1Loop:
     	li $t7, 7
     	bltz $a1, computerMove
     	mul $t7, $t7, $a1
     	add $t8, $t7, $a0
     	sll $t8, $t8, 2
     	lw $t9, board($t8)
     	
     	beqz $t9, move1LoopEnd
     	addi $a1, $a1, -1
     	j move1Loop
	
	move1LoopEnd:
	
	addi $t9, $zero, 2
	sw $t9, board($t8)
    	
    	jal drawPlayerPiece
    	addi $s0, $s0, 1
    	sw $s0, increment($zero)
    	j cpuTurnEnd
       
    	
    	
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   jr $ra
    computerValid:
    addi $a1, $zero, 100
    li $v0, 42  
    syscall
    move $t0, $a0
   
   # Compute Computer's position and return
   addi $t1, $zero, 7
   divu $t0, $t1   
   mfhi $t2            #t2 is the mod with 7 for column
   move $v0, $t2       
   jr $ra              
  computerMove:
        li $a0, 0                         
        li $a1, 6                
        addi $sp, $sp, -4                 
        sw $ra, 0($sp)                  
   
        computer: 
        	  jal computerValid    
                  move $t2, $v0            #moves the random number of $v0 to t2, which will be the column computer will choose
                  blt $t2, $a0, computer #loop back if number is less than 0
                  bgt $t2, $a1, computer   #loop back if number is greater than 6           
                  
        lw $ra, 0($sp) 
        addi $sp, $sp, 4
       
        move $a0, $t2           #x
        addi $a1, $zero, 5
        cpuMoveLoop:
     	li $t7, 7
     	bltz $a1, computerMove
     	mul $t7, $t7, $a1
     	add $t8, $t7, $a0
     	sll $t8, $t8, 2
     	lw $t9, board($t8)
     	
     	beqz $t9, cpuMoveLoopEnd
     	addi $a1, $a1, -1
     	j cpuMoveLoop
     	#check if t9 is 0
     	#if it is zero, we can continue and place the piece
     	#if it is not zero, we increment $a2 by 1 and repeat the above section
     	#except, if after the increment $a2 is greater than 6, in which we send an error
	
	cpuMoveLoopEnd:
	addi $t9, $zero, 2
	sw $t9, board($t8)
        li $a2, 2
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        jal drawPlayerPiece
        # decrement by 1 for next placement 
                                         
        
        #restores registers from stack
        lw $ra, 0($sp)                     
        addi $sp, $sp, 4 
        jr $ra
        
