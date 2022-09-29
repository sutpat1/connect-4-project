.data


.globl checkForWin

.text
#register v0 would be the offset of the coin last placed starting from column 0 and register a0 is the player/comp number (1 = player, computer = 2)
checkForWin:
    addi $sp, $sp, -4
    sw $ra, ($sp)
    la $t8, board($zero) #board base address
    addi $t9, $t8, 164   #board end address
                         #bne loop for checkings for win/lose
    li $a3, 2            #check for cpu, possible win
    cpuWinLoop:
       jal scanTile
       addi $t9, $t9, -4
       blt $t8, $t9, cpuWinLoop
       
    li $a3, 1
    addi $t9, $t8, 164
    cpuLoseLoop:
       jal scanTile
       addi $t9, $t9, -4
       blt $t8, $t9, cpuLoseLoop
       
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    
    scanTile:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, 0($t9)
    bne $a3, $t0, scanTileEnd
    sub $t2, $t9, $t8
    srl $t0, $t2, 2
    li $t1, 7
    div $t0, $t1
    mfhi $t0
    mflo $t7
    
    blt $t2, 81, skipTop
    bgt $t0, 3, skipRight
    jal scanUpRight
    skipRight:
    jal scanUp
    blt $t0, 3, skipLeft
    jal scanUpLeft
    skipTop:
    jal scanLeft
    skipLeft:
    
    scanTileEnd:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    scanUpRight:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
       add $t3, $t9, -24
       lw $t4, 0($t3)
       bne $t4, $a3, scanURend
       add $t3, $t3, -24
       lw $t4, 0($t3)
       bne $t4, $a3, scanURend
       add $t3, $t3, -24
       lw $t4, 0($t3)
       bne $t4, $a3, scanURend
       
       j gameEnd
       
    
       
    scanURend:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    scanUp:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
       add $t3, $t9, -28
       lw $t4, 0($t3)
       bne $t4, $a3, scanUend
       add $t3, $t3, -28
       lw $t4, 0($t3)
       bne $t4, $a3, scanUend
       add $t3, $t3, -28
       lw $t4, 0($t3)
       bne $t4, $a3 scanUend
       
     
       j gameEnd
    
    scanUend:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    scanUpLeft:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
       add $t3, $t9, -32
       lw $t4, 0($t3)
       bne $t4, $a3, scanULend
       add $t3, $t3, -32
       lw $t4, 0($t3)
       bne $t4, $a3, scanULend
       add $t3, $t3, -32
       lw $t4, 0($t3)
       bne $t4, $a3, scanULend
       
       
       j gameEnd
    
    scanULend:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    scanLeft:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
       add $t3, $t9, -4
       lw $t4, 0($t3)
       bne $t4, $a3, scanLend
       add $t3, $t3, -4
       lw $t4, 0($t3)
       bne $t4, $a3, scanLend
       add $t3, $t3, -4
       lw $t4, 0($t3)
       bne $t4, $a3, scanLend
       
       j gameEnd
    
    scanLend:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    
    
    
    
    
