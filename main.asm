.data 
frameBuffer:	.align 2
			.space 0x100000	# set up space for 2d array of pixels
	colorBoard:	.word 0x000000ff# color values written as 0x00RRGGBB
	colorP1:	.word 0x00ff0000
	colorP2:	.word 0x00ffff00
	colorDarker:	.word 0x00999999
	cColmSelect:	.word 1
board:      
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		
ROW_SIZE:	.word 6
COL_SIZE:	.word 7
.eqv DATA_SIZE 4
		 
printInE:	.asciiz "Invalid Move! Try Again!\n"

colIndex:    	.word 0




.globl board inputError drawPlayerPiece gameEnd

.text
	jal drawGameOnBoot
	

     
inputLoop:
	#jal checkForWin
	

	
#Take WASD input    
	li $v0, 12            
     	syscall
     
     	#add	$v0, $zero, 10
	#syscall
   	beq $v0, 'a', colLeft		# select column left
     	beq $v0, 'd', colRight		# select column right
     	beq $v0, 's', makeAMove	# play in current column
     	j inputLoop
              
makeAMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
# Check for invalid input (column full?)
    	la  $a0, board				# base address of board into $a0
     	lw  $a1, COL_SIZE			# num of coloumns into 	     $a1
     	lw $a3, colIndex	
     	jal validInput
# Upload to Array
     	la $a0, board
     	addi $a2, $0, -1			# row index set to -1
     	lw  $a1, COL_SIZE			# num of coloumns into 	     $a1
 #    	jal addValUser				# add to board(next available row)	
#	jal computerValid
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j startingMoves

#addValUser:	#$a0 -> base addr, $a1 -> COL_SIZE,  $a2 -> row index,  $a3 -> coloumn index, 	
#	addi $a2, $zero, 1
#	addi $sp, $sp, -4
#	sw $ra, 0($sp)
#	jal getAt		#result in $v0, address in $v1
#	lw $ra, 0($sp)
#	addi $sp, $sp, 4
	#beqz $v0, addValUser
	# set arguments before call
#	addi $t0, $zero, 1    
#	sw $t0, ($v1)
#	jr $ra

# Check Valid Input
validInput:
# Check if coloumn is full		(getAt function) $a0 -> base addr, $a1 -> COL_SIZE,  $a2 -> row index,  $a3 -> coloumn index
    	addi $a2, $zero, 5			# row index into $a2
    	addi $sp, $sp -4
    	sw $ra, 0($sp)
     	jal getAt
     	# result in $v0
     	#bnez $v0, inputError		# if value is not ZERO (empty), then retake input
     	
     	li $t9, 1
     	li $t7, 7
     	
     	mul $t7, $t7, $a2
     	add $t8, $t7, $a3
     	sll $t8, $t8, 2
     	sw $t9, board($t8)
     	
     	addi $sp, $sp, -20
     	sw $ra, 0($sp)
     	sw $a0, 4($sp)
     	sw $a1, 8($sp)
     	sw $a2, 12($sp)
     	sw $a3, 16($sp)
     	add $a0, $a3, $zero
     	add $a1, $a2, $zero
     	addi $a2, $zero, 1
     	
     	jal drawPlayerPiece
     	
     	lw $ra, 0($sp)
     	lw $a0, 4($sp)
     	lw $a1, 8($sp)
     	lw $a2, 12($sp)
     	lw $a3, 16($sp)
     	addi $sp, $sp, 20
     	
     	lw $ra, 0($sp)
     	addi $sp, $sp, 4
     	jr $ra				# else continue program
     
    
getAt:	#$a0 -> base addr, $a1 -> COL_SIZE,  $a2 -> row index,  $a3 -> coloumn Index
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#move $s1, $t0 
     	#lw  $a3, colIndex
     	#mul $t0, $a1, $a2 		        # row index * COL_SIZE
     	#add $t0, $t0, $a3			# + coloumnIndex
     	#mul $t0, $t0, DATA_SIZE		# * Data Size
     	#add $t0, $t0, $a0			# + base addr
     	#lw  $v0, 0($t0)				# value in $v0
     	#la  $v1, ($t0)
	#move $t0, $s1
	
	
     	
     	
     	getAtLoop:
     	li $t7, 7
     	bltz $a2, inputError
     	mul $t7, $t7, $a2
     	add $t8, $t7, $a3
     	sll $t8, $t8, 2
     	lw $t9, board($t8)
     	
     	beqz $t9, getAtLoopEnd
     	addi $a2, $a2, -1
     	j getAtLoop
     	#check if t9 is 0
     	#if it is zero, we can continue and place the piece
     	#if it is not zero, we increment $a2 by 1 and repeat the above section
     	#except, if after the increment $a2 is greater than 6, in which we send an error
	
	getAtLoopEnd:
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
     	jr  $ra				

     
inputError:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal errorSound
	jal drawColmError
	addi $a0, $zero, 1000
	addi $v0, $zero, 32
	syscall
	jal clearBot
	lw $ra, 0($sp)
	addi $sp, $sp 4
	j inputLoop
     
#------------------
# COLUMN SELECTION
#------------------

# decrement colIndex
colLeft:
	lw $t9, colIndex
	beq $t9, $zero, colLast 		# if first column, select last
	addi $t9, $t9, -1		# otherwise, move one left
	sw $t9, colIndex
	lw $a0, colIndex
	jal colorColmSelect
	j inputLoop
# increment colIndex
colRight:
	lw $t9, colIndex
	lw $t8, COL_SIZE
	sub $t8, $t8, 1			# zero index adjustment
	beq $t9, $t8, colFirst		# if last column, select first
	addi $t9, $t9, 1		# otherwise, move one right
	sw $t9, colIndex
	lw $a0, colIndex
	jal colorColmSelect
	j inputLoop
# set colIndex to the last column
colLast:
	lw $t9, COL_SIZE
	sub $t9, $t9, 1			# zero index adjustment
	sw $t9, colIndex
	lw $a0, colIndex
	jal colorColmSelect
	j inputLoop
# set colIndex to 0
colFirst:
	li $t9, 0
	sw $t9, colIndex
	lw $a0, colIndex
	jal colorColmSelect
	j inputLoop
    
            
        
        
                 


#---------------
# SOUND EFFECTS
#---------------

errorSound:
	li $a0, 72 # pitch (0-127) - this is the C an octave above middle C
	li $a1, 1000 # duration of each sound in milliseconds (1000 = 1 second)
	li $a3, 100 # volume (0-127)
	li $a2, 55
	li $v0, 33
	jr $ra

dropSound:
	li $a0, 67 # pitch (0-127) 
	li $a1, 1000 # duration of each sound in milliseconds (1000 = 1 second)
	li $a3, 100 # volume (0-127)
	li $a2, 117 # instrument 
	li $v0, 33
	syscall
	jr $ra

lostSound:
	li $a0, 70 # pitch (0-127)
	li $a1, 400 # duration of each sound in milliseconds (1000 = 1 second)
	li $a3, 100 # volume (0-127)
	li $a2, 14 # instrument 
	li $t0, 67 # ending pitch
lostSoundLoop:
	li $v0, 33
	syscall
	sub $a0, $a0, 1
	bne $a0, $t0, lostSoundLoop
	sub $a0, $a0, 2
	li $a1, 1000 # duration of each sound in milliseconds (1000 = 1 second)
	li $v0, 33
	syscall
	jr $ra

wonSound:
	li $a0, 67 # pitch (0-127) 
	li $a1, 400 # duration of each sound in milliseconds (1000 = 1 second)
	li $a3, 100 # volume (0-127)
	li $a2, 14 # instrument 
	li $t0, 70 # ending pitch
wonSoundLoop:
	li $v0, 33
	syscall
	addi $a0, $a0, 1
	bne $a0, $t0, wonSoundLoop
	sub $a0, $a0, 2
	li $a1, 1000 # duration of each sound in milliseconds (1000 = 1 second)
	li $v0, 33
	syscall
	jr $ra


     
	
	
drawGameOnBoot:				# the initial drawing of the game board
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	li	$t3, 0
	la	$a0, frameBuffer	# array position
	li	$a1, 16383		# stop point for this draw section
	li	$a2, 0x00ffffff		# color
	jal	drawTop			# draw top white section
	li	$a1, 229376
	lw	$a2, colorBoard
	jal	drawBoard		# draw middle blue board section
	li	$a1, 262144
	li	$a2, 0x00ffffff
	jal	drawBot			# draw bottom white section
	jal	drawInitialField	# draw initial white circles on board
	jal	drawInitialColmSelect	# draw colm select on colm 0
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
drawTop:				#draws above board full white
	sw	$a2, 0($a0)
	addi	$a0, $a0, 4
	addi	$t3, $t3, 1
	bne	$a1, $t3, drawTop
	jr	$ra

	


	
drawBoard:				#draws board full blue no circles yet
	sw	$a2, 0($a0)
	addi	$a0, $a0, 4
	addi	$t3, $t3, 1
	bne	$a1, $t3, drawBoard
	jr	$ra

	
	
drawBot:				#draws below board full white
	sw	$a2, 0($a0)
	addi	$a0, $a0, 4
	addi	$t3, $t3, 1
	bne	$a1, $t3, drawBot
	jr	$ra
	



drawInitialField:			# draw 7x6 white circles of radius 17 in the board
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	
	li	$t4, 46655		# hardcoded start point for first circle
	li	$a2, 17			# circle radius
	li	$a3, 0x00ffffff		# circle color (white)
	li	$s0, 7			# circles per row
	li	$s1, 6			# circles per colm
initialCircleLoop:
	move	$a0, $t4		# match memory position to next circle
	jal	fillCircle		# draw circle at currect memory position
	addi	$s0, $s0, -1
	addi	$t4, $t4, 63		# hard coded value to move to space radius 17 circles (x)
	bnez	$s0, initialCircleLoop	# end of loop for row
	li	$s0, 7			# reset num circles for row on new row
	addi	$t4, $t4, 29767		# hard coded value to move to space radius 17 circles (y)
	addi	$s1, $s1, -1
	bnez	$s1, initialCircleLoop	# end of loop for colm
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra
	
	
drawPlayerPiece:			# Use to fill circle on board at x = $a0, y = $a1, from player $a2
					# (x, y) refers to board 7x6, with top left being (0, 0)
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)		# setup stack point
	
	mul	$a0, $a0, 63
	mul	$a1, $a1, 30208
	add	$a0, $a0, 46655
	add	$a0, $a0, $a1		# set $a0 to pixel number of circle location
	
	lw	$a3, colorP1
	bne	$a2, 2, colorEqual	#decide color of circle
	
	lw	$a3, colorP2
colorEqual:
	add	$a2, $zero, 17
	jal	fillCircle
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
	
drawInitialColmSelect:
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)

	add	$a0, $zero, 51
	add	$a1, $zero, 8
	lw	$a3, colorP1
	add	$s0, $zero, 0
	add	$s1, $zero, 0
	
colmInitialLoop:
	jal drawPoint
	add	$a0, $a0, 1
	add	$s0, $s0, 1
	bne	$s0, 25, colmInitialLoop
	sub	$a0, $a0, $s0
	add	$s0, $zero, 0
	add	$a1, $a1, 1
	add	$s1, $s1, 1
	bne	$s1, 16, colmInitialLoop
	
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra
	
colorColmSelect:
	addi	$sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	
	move	$s2, $a0
	
	lw	$a0, cColmSelect
	mul	$a0, $a0, 63
	add	$a0, $a0, -12
	add	$a1, $zero, 8
	add	$a3, $zero, 0x00ffffff
	add	$s0, $zero, 0
	add	$s1, $zero, 0
	
colmEraseLoop:
	jal drawPoint
	add	$a0, $a0, 1
	add	$s0, $s0, 1
	bne	$s0, 25, colmEraseLoop
	sub	$a0, $a0, $s0
	add	$s0, $zero, 0
	add	$a1, $a1, 1
	add	$s1, $s1, 1
	bne	$s1, 16, colmEraseLoop
	
	
	
	move	$a0, $s2
	addi	$s2, $s2, 1
	sw	$s2, cColmSelect($zero)
	add	$a0, $a0, 1
	mul	$a0, $a0, 63
	add	$a0, $a0, -12
	add	$a1, $zero, 8
	lw	$a3, colorP1
	add	$s0, $zero, 0
	add	$s1, $zero, 0
	
colmColorLoop:
	jal drawPoint
	add	$a0, $a0, 1
	add	$s0, $s0, 1
	bne	$s0, 25, colmColorLoop
	sub	$a0, $a0, $s0
	add	$s0, $zero, 0
	add	$a1, $a1, 1
	add	$s1, $s1, 1
	bne	$s1, 16, colmColorLoop
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
drawColmError:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	addi	$a3, $zero, 0x00000099
	
	add	$a0, $zero, 75
	add	$a1, $zero, 454	
	jal	drawC
	
	add	$a0, $zero, 127
	add	$a1, $zero, 454
	jal	drawO
	
	add	$a0, $zero, 179
	add	$a1, $zero, 454
	jal	drawL
	
	add	$a0, $zero, 259
	add	$a1, $zero, 454
	jal	drawF
	
	add	$a0, $zero, 311
	add	$a1, $zero, 454
	jal	drawU
	
	add	$a0, $zero, 363
	add	$a1, $zero, 454
	jal	drawL
	
	add	$a0, $zero, 415
	add	$a1, $zero, 454
	jal	drawL
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
clearBot:
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	addi	$a3, $zero, 0x00ffffff
	addi	$a0, $zero, 75
	addi	$a1, $zero, 454
	add	$s0, $a1, 48		#clear bot
	add	$a2, $zero, 425
drawClearLoop:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2 
	bne	$a1, $s0, drawClearLoop
	
	
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
		
	
drawEndingWin:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lw	$a3, colorP1
	
	add	$a0, $zero, 75
	add	$a1, $zero, 454	
	jal	drawY
	
	add	$a0, $zero, 127
	add	$a1, $zero, 454
	jal	drawO
	
	add	$a0, $zero, 179
	add	$a1, $zero, 454
	jal	drawU
	
	add	$a0, $zero, 259
	add	$a1, $zero, 454
	jal	drawW
	
	add	$a0, $zero, 311
	add	$a1, $zero, 454
	jal	drawI
	
	add	$a0, $zero, 363
	add	$a1, $zero, 454
	jal	drawN
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
drawEndingLose:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lw	$a3, colorP1
	
	add	$a0, $zero, 75
	add	$a1, $zero, 454	
	jal	drawY
	
	add	$a0, $zero, 127
	add	$a1, $zero, 454
	jal	drawO
	
	add	$a0, $zero, 179
	add	$a1, $zero, 454
	jal	drawU
	
	add	$a0, $zero, 259
	add	$a1, $zero, 454
	jal	drawL
	
	add	$a0, $zero, 311
	add	$a1, $zero, 454
	jal	drawO
	
	add	$a0, $zero, 363
	add	$a1, $zero, 454
	jal	drawS
	
	add	$a0, $zero, 415
	add	$a1, $zero, 454
	jal	drawE
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
drawEndingTie:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lw	$a3, colorP1
	
	add	$a0, $zero, 75
	add	$a1, $zero, 454	
	jal	drawY
	
	add	$a0, $zero, 127
	add	$a1, $zero, 454
	jal	drawO
	
	add	$a0, $zero, 179
	add	$a1, $zero, 454
	jal	drawU
	
	add	$a0, $zero, 259
	add	$a1, $zero, 454
	jal	drawT
	
	add	$a0, $zero, 311
	add	$a1, $zero, 454
	jal	drawI
	
	add	$a0, $zero, 363
	add	$a1, $zero, 454
	jal	drawE
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra


fillCircle:				# fill circle at pixel $a0, radius $a2, with color $a3

	addi	$sp, $sp, -28
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 16($sp)
	sw	$s3, 20($sp)
	sw	$a3, 24($sp)
	
	add	$s0, $a2, $zero		# needed for keeping the initial radius saved between func calls
	li	$t0, 512		# hard coded value to seperate x and y values in the memory address
	div	$a0, $t0
	mfhi	$a0			# remainder = x cord = $a0
	mflo	$a1			# quotient  = y cord = $a1
	
	
	
	

fillCircleLoop:
	jal	drawCircle		# draw circle at x,y cords, (just outline, not filled!
	addi	$a2, $a2, -1		# reduce radius by 1 and loop to fill in circle
	bnez	$a2, fillCircleLoop
	
fillStrayPixels:
	lw	$s3, colorDarker
	and	$a3, $a3, $s3
	add	$s1, $zero, $a0
	add	$s2, $zero, $a1
	
	
	jal	drawPoint
	
	# next set of pixels
	add	$a0, $s1, 1
	add	$a1, $s2, 1
	jal	drawPoint
		
	add	$a0, $s1, -1
	add	$a1, $s2, 1
	jal	drawPoint
	
	add	$a0, $s1, 1
	add	$a1, $s2, -1
	jal	drawPoint

	add	$a0, $s1, -1
	add	$a1, $s2, -1
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 2
	add	$a1, $s2, 4
	jal	drawPoint
		
	add	$a0, $s1, -2
	add	$a1, $s2, 4
	jal	drawPoint
	
	add	$a0, $s1, 2
	add	$a1, $s2, -4
	jal	drawPoint

	add	$a0, $s1, -2
	add	$a1, $s2, -4
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 4
	add	$a1, $s2, 2
	jal	drawPoint
		
	add	$a0, $s1, -4
	add	$a1, $s2, 2
	jal	drawPoint
	
	add	$a0, $s1, 4
	add	$a1, $s2, -2
	jal	drawPoint

	add	$a0, $s1, -4
	add	$a1, $s2, -2
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 4
	add	$a1, $s2, 5
	jal	drawPoint
		
	add	$a0, $s1, -4
	add	$a1, $s2, 5
	jal	drawPoint
	
	add	$a0, $s1, 4
	add	$a1, $s2, -5
	jal	drawPoint

	add	$a0, $s1, -4
	add	$a1, $s2, -5
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 5
	add	$a1, $s2, 4
	jal	drawPoint
		
	add	$a0, $s1, -5
	add	$a1, $s2, 4
	jal	drawPoint
	
	add	$a0, $s1, 5
	add	$a1, $s2, -4
	jal	drawPoint

	add	$a0, $s1, -5
	add	$a1, $s2, -4
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 6
	add	$a1, $s2, 6
	jal	drawPoint
		
	add	$a0, $s1, -6
	add	$a1, $s2, 6
	jal	drawPoint
	
	add	$a0, $s1, 6
	add	$a1, $s2, -6
	jal	drawPoint

	add	$a0, $s1, -6
	add	$a1, $s2, -6
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 5
	add	$a1, $s2, 8
	jal	drawPoint
		
	add	$a0, $s1, -5
	add	$a1, $s2, 8
	jal	drawPoint
	
	add	$a0, $s1, 5
	add	$a1, $s2, -8
	jal	drawPoint

	add	$a0, $s1, -5
	add	$a1, $s2, -8
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 8
	add	$a1, $s2, 5
	jal	drawPoint
		
	add	$a0, $s1, -8
	add	$a1, $s2, 5
	jal	drawPoint
	
	add	$a0, $s1, 8
	add	$a1, $s2, -5
	jal	drawPoint

	add	$a0, $s1, -8
	add	$a1, $s2, -5
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 3
	add	$a1, $s2, 9
	jal	drawPoint
		
	add	$a0, $s1, -3
	add	$a1, $s2, 9
	jal	drawPoint
	
	add	$a0, $s1, 3
	add	$a1, $s2, -9
	jal	drawPoint

	add	$a0, $s1, -3
	add	$a1, $s2, -9
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 9
	add	$a1, $s2, 3
	jal	drawPoint
		
	add	$a0, $s1, -9
	add	$a1, $s2, 3
	jal	drawPoint
	
	add	$a0, $s1, 9
	add	$a1, $s2, -3
	jal	drawPoint

	add	$a0, $s1, -9
	add	$a1, $s2, -3
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 7
	add	$a1, $s2, 9
	jal	drawPoint
		
	add	$a0, $s1, -7
	add	$a1, $s2, 9
	jal	drawPoint
	
	add	$a0, $s1, 7
	add	$a1, $s2, -9
	jal	drawPoint

	add	$a0, $s1, -7
	add	$a1, $s2, -9
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 9
	add	$a1, $s2, 7
	jal	drawPoint
		
	add	$a0, $s1, -9
	add	$a1, $s2, 7
	jal	drawPoint
	
	add	$a0, $s1, 9
	add	$a1, $s2, -7
	jal	drawPoint

	add	$a0, $s1, -9
	add	$a1, $s2, -7
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 6
	add	$a1, $s2, 11
	jal	drawPoint
		
	add	$a0, $s1, -6
	add	$a1, $s2, 11
	jal	drawPoint
	
	add	$a0, $s1, 6
	add	$a1, $s2, -11
	jal	drawPoint

	add	$a0, $s1, -6
	add	$a1, $s2, -11
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 11
	add	$a1, $s2, 6
	jal	drawPoint
		
	add	$a0, $s1, -11
	add	$a1, $s2, 6
	jal	drawPoint
	
	add	$a0, $s1, 11
	add	$a1, $s2, -6
	jal	drawPoint

	add	$a0, $s1, -11
	add	$a1, $s2, -6
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 8
	add	$a1, $s2, 12
	jal	drawPoint
		
	add	$a0, $s1, -8
	add	$a1, $s2, 12
	jal	drawPoint
	
	add	$a0, $s1, 8
	add	$a1, $s2, -12
	jal	drawPoint

	add	$a0, $s1, -8
	add	$a1, $s2, -12
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 12
	add	$a1, $s2, 8
	jal	drawPoint
		
	add	$a0, $s1, -12
	add	$a1, $s2, 8
	jal	drawPoint
	
	add	$a0, $s1, 12
	add	$a1, $s2, -8
	jal	drawPoint

	add	$a0, $s1, -12
	add	$a1, $s2, -8
	jal	drawPoint
	

		# next set of pixels
	add	$a0, $s1, 9
	add	$a1, $s2, 10
	jal	drawPoint
		
	add	$a0, $s1, -9
	add	$a1, $s2, 10
	jal	drawPoint
	
	add	$a0, $s1, 9
	add	$a1, $s2, -10
	jal	drawPoint

	add	$a0, $s1, -9
	add	$a1, $s2, -10
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 10
	add	$a1, $s2, 9
	jal	drawPoint
		
	add	$a0, $s1, -10
	add	$a1, $s2, 9
	jal	drawPoint
	
	add	$a0, $s1, 10
	add	$a1, $s2, -9
	jal	drawPoint

	add	$a0, $s1, -10
	add	$a1, $s2, -9
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 11
	add	$a1, $s2, 11
	jal	drawPoint
		
	add	$a0, $s1, -11
	add	$a1, $s2, 11
	jal	drawPoint
	
	add	$a0, $s1, 11
	add	$a1, $s2, -11
	jal	drawPoint

	add	$a0, $s1, -11
	add	$a1, $s2, -11
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 10
	add	$a1, $s2, 13
	jal	drawPoint
		
	add	$a0, $s1, -10
	add	$a1, $s2, 13
	jal	drawPoint
	
	add	$a0, $s1, 10
	add	$a1, $s2, -13
	jal	drawPoint

	add	$a0, $s1, -10
	add	$a1, $s2, -13
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 13
	add	$a1, $s2, 10
	jal	drawPoint
		
	add	$a0, $s1, -13
	add	$a1, $s2, 10
	jal	drawPoint
	
	add	$a0, $s1, 13
	add	$a1, $s2, -10
	jal	drawPoint

	add	$a0, $s1, -13
	add	$a1, $s2, -10
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 4
	add	$a1, $s2, 16
	jal	drawPoint
		
	add	$a0, $s1, -4
	add	$a1, $s2, 16
	jal	drawPoint
	
	add	$a0, $s1, 4
	add	$a1, $s2, -16
	jal	drawPoint

	add	$a0, $s1, -4
	add	$a1, $s2, -16
	jal	drawPoint
	
		# next set of pixels
	add	$a0, $s1, 16
	add	$a1, $s2, 4
	jal	drawPoint
		
	add	$a0, $s1, -16
	add	$a1, $s2, 4
	jal	drawPoint
	
	add	$a0, $s1, 16
	add	$a1, $s2, -4
	jal	drawPoint

	add	$a0, $s1, -16
	add	$a1, $s2, -4
	jal	drawPoint
	
		
	add	$a2, $s0, $zero		# reset $a2 to initial radius before moving to next circle
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 16($sp)
	lw	$s3, 20($sp)
	lw	$a3, 24($sp)
	addi	$sp, $sp, 28
	jr	$ra
	
drawCircle:				#draw circle at x = $a0, y = $a1, radius $a2, using color $a3
	
	addi	$sp, $sp, -32
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	sw	$s0, 12($sp)
	sw	$s1, 16($sp)
	sw	$s2, 20($sp)
	sw	$s3, 24($sp)
	sw	$s4, 28($sp)
	
	move $s3, $a0
	move $s4, $a1
	
	li	$s0, 1			# setup intial circle algorithm variables
	sub	$s0, $s0, $a2		
	
	li	$s1, 0
	
	mul	$s2, $a2, -2
	
	li	$t8, 0
	
	move	$t9, $a2
	
	add	$a0, $s3, $zero
	add	$a1, $s4, $a2
	jal	drawPoint		# draw initial 4 points (top bottem left right)
	add	$a0, $s3, $zero
	sub	$a1, $s4, $a2
	jal	drawPoint
	add	$a0, $s3, $a2
	add	$a1, $s4, $zero
	jal	drawPoint
	sub	$a0, $s3, $a2
	add	$a1, $s4, $zero
	jal	drawPoint
	
theCircleLoop:
	bge	$t8, $t9, exitCircleLoop
	bltz	$s0, circleSkip
	addi	$t9, $t9, -1
	addi	$s2, $s2, 2
	add	$s0, $s0, $s2
circleSkip:
	addi	$t8, $t8, 1		# update circle algorithm variables
	addi	$s1, $s1, 2
	add	$s0, $s0, $s1
	addi	$s0, $s0, 1
	
	add	$a0, $s3, $t8
	add	$a1, $s4, $t9
	jal	drawPoint		# draw next point and mirror it into other 7 symetrical sections of the circle
	
	sub	$a0, $s3, $t8
	add	$a1, $s4, $t9
	jal	drawPoint
	
	add	$a0, $s3, $t8
	sub	$a1, $s4, $t9
	jal	drawPoint
	
	sub	$a0, $s3, $t8
	sub	$a1, $s4, $t9
	jal	drawPoint
	
	add	$a0, $s3, $t9
	add	$a1, $s4, $t8
	jal	drawPoint
	
	sub	$a0, $s3, $t9
	add	$a1, $s4, $t8
	jal	drawPoint
	
	add	$a0, $s3, $t9
	sub	$a1, $s4, $t8
	jal	drawPoint
	
	sub	$a0, $s3, $t9
	sub	$a1, $s4, $t8
	jal	drawPoint
	
	j	theCircleLoop
	
exitCircleLoop:
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	lw	$s0, 12($sp)
	lw	$s1, 16($sp)
	lw	$s2, 20($sp)
	lw	$s3, 24($sp)
	lw	$s4, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra
	
drawY:					# draw letter Y in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 24		# draw left of Y
	add	$a2, $zero, 12
drawYLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawYLoop1
	
	add	$a0, $a0, 36
	add	$a1, $a1, -24
	add	$s0, $a1, 24		# draw right of Y
	add	$a2, $zero, 12
drawYLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2 
	bne	$a1, $s0, drawYLoop2
	
	add	$a0, $a0, -36
	add	$a1, $a1, -6
	add	$s0, $a1, 12		# draw mid of Y
	add	$a2, $zero, 48
drawYLoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2 
	bne	$a1, $s0, drawYLoop3
	
	add	$a0, $a0, 18
	add	$s0, $a1, 18		# draw botmid of Y
	add	$a2, $zero, 12
drawYLoop4:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2 
	bne	$a1, $s0, drawYLoop4
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
drawO:					# draw letter O in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 48		# draw left of O
	add	$a2, $zero, 12
drawOLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawOLoop1
	
	add	$a1, $a1, -48
	add	$a0, $a0, 36
	
	add	$s0, $a1, 48		# draw right of O
	add	$a2, $zero, 12
drawOLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawOLoop2
	
	add	$a0, $a0, -36
	add	$a1, $a1, -12
	
	add	$s0, $a1, 12		# draw bot of O
	add	$a2, $zero, 48
drawOLoop3:				
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawOLoop3
	
	add	$a1, $a1, -48
	add	$s0, $a1, 12
	add	$a0, $a0, 12		# draw top of O
	add	$a2, $zero, 24
drawOLoop4:				
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawOLoop4
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
drawU:					# draw letter U in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 48		# draw left of U
	add	$a2, $zero, 12
drawULoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawULoop1
	
	add	$a1, $a1, -48
	add	$a0, $a0, 36
	
	add	$s0, $a1, 48		# draw right of U
	add	$a2, $zero, 12
drawULoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawULoop2
	
	add	$a0, $a0, -36
	add	$a1, $a1, -12
	add	$s0, $a1, 12
	add	$a2, $zero, 48
drawULoop3:				# draw bot of U
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawULoop3
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawW:					# draw letter W in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 48		# draw left of W
	add	$a2, $zero, 12
drawWLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawWLoop1
	
	add	$a1, $a1, -48
	add	$a0, $a0, 36
	
	add	$s0, $a1, 48		# draw right of W
	add	$a2, $zero, 12
drawWLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawWLoop2
	
	add	$a1, $a1, -44
	add	$a0, $a0, -18
	
	add	$s0, $a1, 44		# draw mid of W
	add	$a2, $zero, 8
drawWLoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawWLoop3
	
	add	$a1, $a1, -12
	add	$s0, $a1, 12
	add	$a0, $a0, -18
	add	$a2, $zero, 48
drawWLoop4:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawWLoop4
	
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
drawI:					# draw letter I in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 12		# draw top of I
	add	$a2, $zero, 48
drawILoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawILoop1
	
	add	$s0, $a1, 24		# draw mid of I
	add	$a2, $zero, 12
	add	$a0, $a0, 18
drawILoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawILoop2
	
	add	$s0, $a1, 12		# draw bot of I
	add	$a2, $zero, 48
	add	$a0, $a0, -18
drawILoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawILoop3
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawN:					# draw letter N in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 48		# draw left of N
	add	$a2, $zero, 12
drawNLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawNLoop1
	
	add	$a1, $a1, -48
	add	$a0, $a0, 36
	
	add	$s0, $a1, 48		# draw right of N
	add	$a2, $zero, 12
drawNLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawNLoop2
	
	add	$a1, $a1, -42
	add	$a0, $a0, -36
	
	add	$s0, $a1, 36		# draw mid of N
	add	$a2, $zero, 12
drawNLoop3:
	jal	drawLine
	add	$a1, $a1, 1
	add	$a0, $a0, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawNLoop3
	
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra

drawL:					# draw letter L in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 36		# draw top of L
	add	$a2, $zero, 12
drawLLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawLLoop1
	
	add	$s0, $a1, 12		# draw bot of L
	add	$a2, $zero, 48
drawLLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawLLoop2
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
drawS:					# draw letter S in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 12		# draw top of S
	add	$a2, $zero, 48
drawSLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop1
	
	add	$s0, $a1, 8		# draw topmid of S
	add	$a2, $zero, 12
drawSLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop2
	
	add	$s0, $a1, 8		# draw mid of S
	add	$a2, $zero, 48
drawSLoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop3
	
	add	$s0, $a1, 8		# draw botmid of S
	add	$a2, $zero, 12
	add	$a0, $a0, 36
drawSLoop4:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop4
	
	add	$s0, $a1, 12		# draw bot of S
	add	$a2, $zero, 48
	add	$a0, $a0, -36
drawSLoop5:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop5
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawE:					# draw letter E in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 12		# draw top E
	add	$a2, $zero, 48
drawELoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop1
	
	add	$s0, $a1, 8		# draw topmid of E
	add	$a2, $zero, 12
drawELoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop2
	
	add	$s0, $a1, 8		# draw mid of E
	add	$a2, $zero, 24
drawELoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop3
	
	add	$s0, $a1, 8		# draw botmid of E
	add	$a2, $zero, 12
drawELoop4:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop4
	
	add	$s0, $a1, 12		# draw bot of E
	add	$a2, $zero, 48
drawELoop5:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop5
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra

drawT:					# draw letter T in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 12		# draw top of T
	add	$a2, $zero, 48
drawTLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawTLoop1
	
	add	$s0, $a1, 36		# draw bot of T
	add	$a2, $zero, 12
	add	$a0, $a0, 18
drawTLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawTLoop2
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawC:
	
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 48		# draw left of C
	add	$a2, $zero, 12
drawCLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawCLoop1
	
	add	$a1, $a1, -48
	add	$a0, $a0, 12
	
	add	$s0, $a1, 12		# draw top of C
	add	$a2, $zero, 36
drawCLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawCLoop2
	
	
	add	$a1, $a1, 24
	
	add	$s0, $a1, 12		# draw bot of C
	add	$a2, $zero, 36
drawCLoop3:				
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawCLoop3
	

	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawF:
addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 12		# draw top E
	add	$a2, $zero, 48
drawFLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawFLoop1
	
	add	$s0, $a1, 8		# draw topmid of E
	add	$a2, $zero, 12
drawFLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawFLoop2
	
	add	$s0, $a1, 8		# draw mid of E
	add	$a2, $zero, 24
drawFLoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawFLoop3
	
	add	$s0, $a1, 20		# draw botmid of E
	add	$a2, $zero, 12
drawFLoop4:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawFLoop4
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawLine:			# draw horizontal line from x=$a0, y=$a1, length=$a2, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a2, $a0
	jal	drawPoint
dlLoop:
	add	$a0, $a0, 1
	jal	drawPoint
	bne	$a0, $s0, dlLoop
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	

drawPoint:				# fills point at x = $a0, y = $a1, with color $a3
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	add	$t2, $a0, $zero		# add y cord to total
	sll	$t1, $a1, 9		# mult y cord by 512 to revert back into 1d array of pixels
	add	$t2, $t2, $t1		# add x cord to total
	sll	$t2, $t2, 2		# align total to word address
	la	$t0, frameBuffer	# setup initial memory address of pixels
	add	$t0, $t0, $t2		# add memory address to total to get to final positon
	sw	$a3, 0($t0)		# draw the pixel with color $a3
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
gameEnd:
	blt $a3, 2, playerWin
	
cpuWin:
	jal drawEndingLose

	addi $v0, $zero, 10
	syscall

playerWin:

	jal drawEndingWin

	addi $v0, $zero, 10
	syscall
