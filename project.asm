#Matthew Bedford mdb190007
#CS 2340.0W1
#Final Project

#Use bitmap display and keyboard simulator
#Set bitmap to 4 unit width and height in pixels 
#Set bitmap to 256x256 with base address 0x10008000 ($gp)

###############DESCRIPTION######################
#This is Minesweeper.
#In this game you try to fine all of the mines in the minefield without blowing them. You do this by clearing all of the spaces that are not mines. 
#the field is 7x7 meaning it has 49 spaces. There are 14 bombs. Each time you clear a space that is not a bomb, it will have a number signifiying 
#how many bombs are immediately next to the space. This means one space in any direction of the square. Up, left, right, down, and all of the corners
#i.e. top left, bottom left, top right, bottom right. You use this number to find whre you think bombs will be and not. You then place a marker where
#you believe bombs to be so you do not hit them. You go through the field clearing all of the spaces you believe to not be bombs. Once you clear 35 spaces,
#then you win because the rest are bombs. If you hit a bomb, you lose. Most of the time these fields can be solved mathematically but there will be points where are you meant to guess. 

###############CONTROLS#######################
#press <enter> to start the game from the start screen. Once the game starts wait until a blue indicator appears. that indicator can be moved with wasd.
#any space you believe to be a bomb can be marked with f. Any space you believe to be safe you can clear with <space>. BEWARE, if you clear a space with a bomb
#you will lose. If you identify all 14 bombs and clear the other 35 spaces, you will win. If you mark an already cleared space it is intended to erase the value there
#and then mark it. If you accidentally do that then you can just clear the space again.

#constants
.eqv WIDTH 64
.eqv HEIGHT 64
#0,0
.eqv MEM 0x10010000
#colors
.eqv	RED 	0x00FF0000
.eqv	GREEN	0x0000FF00
.eqv	BLUE	0x000000FF
.eqv	WHITE	0x00FFFFFF
.eqv	YELLOW	0x00FFFF00
.eqv	CYAN	0x0000FFFF
.eqv	MAGENTA	0x00FF00FF

.data
bombArray: 	.word	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		#will store bomb data
checkArray:	.word	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		#will store bomb checked data

.text
#main program
main:
	jal	start_Screen				#introduces user to program
	
	#function to capture the inputs of the user
	userStartInput:
		lw 	$t0, 0xffff0000
		beq 	$t0, 0, userStartInput		#check for input
		lw	$s4, 0xffff0004			#if input then capture it
		beq	$s4, 10, game_StartJAL		#if input <enter> then jump to game_StartJAL
		beq	$s4, 32, select_Square		#if input <space> then jump to select_Square
		beq 	$s4, 119, indicator_UP		#if input w then jump to indicator_UP
		beq	$s4, 115, indicator_DOWN	#if input s then jump to indicator_DOWN
		beq 	$s4, 97, indicator_LEFT		#if input a then jump to indicator_LEFT
		beq	$s4, 100, indicator_RIGHT	#if input d then jump to indicator_RIGHT
		beq	$s4, 102, place_MarkerJAL	#if input f then jump to place_MarkerJAL
		j	userStartInput			#repeat check for input continually until program ends
	
	#function to start the game when the user presses <enter>
	game_StartJAL:
		bge	$s0, 1, userStartInput		#$s0 tracks status of the program. if at 0, has not been started. 1, in progress. 2, end. this prevents game from being started while going or done.
		jal	game_Start			#if at 0, then the game will be started with game_Start function
		addi 	$a2, $0, BLUE			#set color for the selection indicator
		add	$s1, $0, $gp			#set place of indicator at 0,0
		li	$s0, 1				#status tracker
		li	$s2, 35				#tracker for how many correctly cleared
		li	$s6, 1				#tracker for position in array
		jal	selection_Indicator		#call selection_Indicator to draw it from 0,0
		j	userStartInput			#jump back to looking for input
		
	#function to move the selection indicator up when user presses w
	indicator_UP:					
		bge	$s0, 2, userStartInput		#if the status of program is at end, then the pixel pointer cannot be moved
		ble	$s6, 7, userStartInput		#if within the first 7 locations, then the indicator CANNOT go up.  (Up of farthest up)
		addi	$s6, $s6, -7			#if it does go up, change the position in array by -7 as that is where UP is in the array
		addi 	$a2, $0, 0			#before moving change the current selection indicator to black to return the lines to how they were
		jal	selection_Indicator
		addi 	$s1, $s1, -2304			#then move a row up and print selection_indicator as blue
		addi	$a2, $0, BLUE
		jal	selection_Indicator
		j 	userStartInput			#return to user input to keep checking for input
		
	#function to move the selection indicator down when user presses s
	indicator_DOWN:					
		bge	$s0, 2, userStartInput		
		bge	$s6, 43, userStartInput		#bottom of array is greater than or equal to 43rd position  (Down of farthest down)
		addi	$s6, $s6, 7			#to move down increment by 7
		addi 	$a2, $0, 0	
		jal	selection_Indicator
		addi 	$s1, $s1, 2304
		addi	$a2, $0, BLUE
		jal	selection_Indicator
		j 	userStartInput			
		
	#function to move the selection indicator left when user presses a
	indicator_LEFT:					
		bge	$s0, 2, userStartInput		
		div	$t1, $s6, 7
		mfhi	$t1
		beq	$t1, 1, userStartInput		#if the user tries to go left while in array column 1, it will NOT work. (Left of farthest left)
		addi	$s6, $s6, -1			#to go left in array decrease by 1
		addi 	$a2, $0, 0	
		jal	selection_Indicator
		addi 	$s1, $s1, -36
		addi	$a2, $0, BLUE
		jal	selection_Indicator
		j 	userStartInput			
	
	#function to move the selection indicator right when user presses d	
	indicator_RIGHT:				
		bge	$s0, 2, userStartInput		
		div	$t1, $s6, 7
		mfhi	$t1
		beq	$t1, 0, userStartInput		#if the user tries to go right wile in array column 8, it will NOT work. (Right of farthest right)
		addi	$s6, $s6, 1			#to go right in array increase by 1
		addi 	$a2, $0, 0	
		jal	selection_Indicator
		addi 	$s1, $s1, 36
		addi	$a2, $0, BLUE
		jal	selection_Indicator
		j 	userStartInput			
	
	#function to select the square being hovered by the user when the user presses <space>
	select_Square:
		jal	check_Space			#call function to check the spot selected on the display in the according array spot
		j	userStartInput			#return to user input to keep checking for input
	
	#function to jal place_Marker when user presses f	
	place_MarkerJAL:
		jal	place_Marker			#call function to print out the marker
		j	userStartInput			#return to user input to keep checking for input
	
	#function to end the program	
	end:
		li	$v0, 10
		syscall

#function to draw the start screen
start_Screen:
	addi 	$a2, $0, WHITE				#set color white
	add	$s1, $0, $gp				#set 0,0
	move	$s5, $ra				#store return address
	addi	$s1, $s1, 3392				#place pointer where wanted
	jal 	m					#use functions to print MINE
	jal 	i
	jal 	n
	jal 	e
	addi	$s1, $s1, 2128				#move pointer down
	jal 	s					#use functions to print SWEEPER
	jal 	w
	jal 	e
	jal 	e
	jal 	p
	jal 	e
	jal 	r
	addi	$s1, $s1, 3640				#move pointer down
	jal	angle_bracketOpen			#use functions to print <ENTER>
	jal	e
	jal	n
	jal	t
	jal	e
	jal	r
	jal	angle_bracketClose
	addi	$s1, $s1, 2092				#move pointer down
	jal	t					#use functions to print TO
	jal	o
	addi	$s1, $s1, 24				#move pointer over
	jal	s					#use functions to print START
	jal	t
	jal	a
	jal	r
	jal	t
	addi	$s1, $s1, 2880				#move pointer down
	jal	mdb190007				#use function to print MDB190007
	
	jr	$s5					#return to where called from

#function to start the game
game_Start:
	move	$s5, $ra				#store return address 
	jal	black_Screen				#reset screen
	jal	game_Lines				#draw in the lines
	jal	create_Bombs				#create the bomb array to play with
	jr	$s5					#go to return address

#function to color the screen the base color for reset purposes. named black screen but is actually white 
black_Screen:						#for screen reset
	add	$s1, $0, $gp				#start pointer at 0,0
	addi	$t1, $0, 0				#start counter at 0
	addi 	$a2, $0, WHITE				#load color WHITE
	
	loopBlack: 					#loop though each pixel and color it WHITE
		sw	$a2, 0($s1)
		addi	$t1, $t1, 1
		beq	$t1, 4096, black_done
		addi	$s1, $s1, 4
		j	loopBlack
		
	black_done:					#after everything has been colored return to where called
		jr	$ra

#draw the lines that will create the 7x7 grid that holds the 49 boxes that are the minefield
game_Lines:
	addi 	$a2, $0, 0				#set color black for lines
	add	$s1, $0, $gp				#set pointer to 0,0
	addi	$t1, $0, 0				#counter for inside loop
	addi	$t2, $0, 0				#counter for ouside loop
	loop_Vertical:					#loop to draw all of the vertical lines
		sw	$a2, 0($s1)
		addi	$t1, $t1, 1
		addi	$s1, $s1, 36
		bne	$t1, 7, loop_Vertical		#color every beginning of a vertical line until counter 1 is at 7, then it is time for next line
		addi	$t1, $0, 0			#reset counter 1
		addi	$t2, $t2, 1			#increment counter 2
		beq	$t2, 64, loop_Horizontal	#if counter 2 is 64 for every pixel in a line then move to horizontal as vertical are done
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		j	loop_Vertical			#else continue vertical
		
	loop_Horizontal:
		sw	$a2, 0($s1)
		add	$s1, $0, $gp
		addi	$t2, $0, 0
		loopH:					#color in the horizontal lines in the same process
		sw	$a2, 0($s1)
		addi	$t1, $t1, 1
		addi	$s1, $s1, 4
		bne	$t1, 64, loopH
		addi	$t1, $0, 0
		addi	$t2, $t2, 1
		beq	$t2, 64, lines_Done
		addi	$s1, $s1, 2048
		j	loopH
	
	lines_Done:					#once the lines are done return to where function was called to continue
	jr	$ra

#function to create the selection indicator so that it can be moved around easily
selection_Indicator:
	li	$t1, 0
	#loop to draw the pixels of the top side of the indicator
	indicator_top:
		sw	$a2, 0($s1)
		addi	$t1, $t1, 1
		beq	$t1, 9, indicator_right
		addi	$s1, $s1, 4
		j	indicator_top
		
	#loop to draw the pixels of the right side of the indicator	
	indicator_right:
		li	$t1, 0
		addi	$s1, $s1, 4
		loop_right:
			sw	$a2, 0($s1)
			addi	$t1, $t1, 1
			beq	$t1, 9, indicator_bot
			addi	$s1, $s1,256
			j	loop_right
			
	#loop to draw the pixels of the bottom side of the indicator
	indicator_bot:
		li	$t1, 0
		addi	$s1, $s1, 256
		loop_bot:
			sw	$a2, 0($s1)
			addi	$t1, $t1, 1
			beq	$t1, 9, indicator_left
			addi	$s1, $s1, -4
			j	loop_bot
			
	#loop to draw the pixels of the left side of the indicator
	indicator_left:
		li	$t1, 0
		addi	$s1, $s1, -4
		loop_left:
			sw	$a2, 0($s1)
			addi	$t1, $t1, 1
			beq	$t1, 9, indicator_done
			addi	$s1, $s1, -256
			j	loop_left
	
	#once it is done reset the position of the pointer back to the start for movement purposes
	indicator_done:
		addi	$s1, $s1, -256
			
	jr	$ra

#this function will randomly create an array of 14 bombs and the proper values of how many bombs are next to each space
#this way, everytime this program is run, it is a different game and not static
create_Bombs: 
	li	$t0, 14						#target # of bombs
	li	$t1, 0						#current # of bombs
	la	$t2, bombArray					#load array of bombs
	li	$t3, 0						#current position in array 
	
	bomb_loop:
		bne	$t3, 49, noReset			#if the array has been gone through and there is still not 14 bombs, then it must be pointed back to the
		addi	$t3, $0, 0				#front of the array so that the function can continue until 14 bombs are created
		la	$t2, bombArray
		noReset:
		addi 	$a1, $0, 10			
		li	$v0, 42	
		syscall						#generate random number
		addi	$t3, $t3, 1				#increment position # in array because this is easiest but not actual position because it may still need to be used
		beq	$a0, 9, bomb				#if the random value 0-9 = 9, then the current position in the array will be set to a bomb
		addi	$t2, $t2, 4				#if not, then the loop procedes to the next position in the array and continues until there are 14 bombs
		j	bomb_loop
		
		#funciton for finding the place of the bomb
		bomb: 						#If the random number is a 9, then the process of adding the bomb begins. (Which is lengthy)
			lb	$t6, ($t2)			#first load the current byte of the array and check it's value to make sure it's not already a bomb
			bge	$t6, 9, alreadyBomb		#if it is greater than 9 then it is a bomb and doubling up would create a massive bug
			sw	$a0, ($t2)			
			addi	$t1, $t1, 1			#otherwise, store the 9 in the current address of the array and go through the process of finding where on the field it is because each place adds the numbers around the bomb differently
			beq	$t3, 1, top_leftCorner		#if the counter is at 1, then it is at the top left and that function is called
			beq	$t3, 7, top_rightCorner		#if at 7, then top right
			beq	$t3, 43, bottom_leftCorner	#43, bottom left
			beq	$t3, 49, bottom_rightCorner	#49, bottom right
			blt	$t3, 7, top_rowMiddle		#now we have to check for the top row. if it is less than 7 then it is top row
			bgt	$t3, 43, bottom_rowMiddle	#greater than 43, then in the bottom row
			div	$t4, $t3, 7			
			mfhi	$t4				#now if still not placed do modulus 7 of the number
			beq	$t4, 1,	left_columnMiddle	#if remainder of one, it is in the far left column
			beq	$t4, 0, right_columnMiddle	#if remainder of 0, it is in the far right column
			j	middle				#otherwise, it is somewhere in the middle
		
		top_leftCorner:					#if in top left corner, then boxes to right, bot right, bot
			addi	$t2, $t2, 4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase right
			sb	$t7, ($t2)
			addi	$t2, $t2, 24
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bot
			sb	$t7, ($t2)
			addi	$t2, $t2, 4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bot right
			sb	$t7, ($t2)
			addi	$t2, $t2, -28
			beq	$t0, $t1, fullBombs
			j	bomb_loop
		
		top_rightCorner:				#if in top right corner, then boxes to left, bot left, bot
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase left
			sb	$t7, ($t2)
			addi	$t2, $t2, 32
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bot
			sb	$t7, ($t2)
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bot left
			sb	$t7, ($t2)
			addi	$t2, $t2, -20
			beq	$t0, $t1, fullBombs
			j	bomb_loop
			
		bottom_leftCorner:				#if in bot left corner, then boxes to right, top right, top
			addi	$t2, $t2, 4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase right
			sb	$t7, ($t2)
			addi	$t2, $t2, -32
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top
			sb	$t7, ($t2)
			addi	$t2, $t2, 4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top right
			sb	$t7, ($t2)
			addi	$t2, $t2, 28
			beq	$t0, $t1, fullBombs
			j	bomb_loop
		
		bottom_rightCorner:				#if in bot right corner, then boxes to left, top left, top
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase left
			sb	$t7, ($t2)
			addi	$t2, $t2, -24
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top
			sb	$t7, ($t2)
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top left
			sb	$t7, ($t2)
			addi	$t2, $t2, 36
			beq	$t0, $t1, fullBombs
			j	bomb_loop
			
		top_rowMiddle:					#if in middle of top row, then boxes to right, bot right, bot, bot left, left
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase left
			sb	$t7, ($t2)
			addi	$t2, $t2, 28
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bot left
			sb	$t7, ($t2)
			addi	$t2, $t2, -28
			addi	$t2, $t2, 8
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase right
			sb	$t7, ($t2)
			addi	$t2, $t2, 28
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bot right
			sb	$t7, ($t2)
			addi	$t2, $t2, -28
			addi	$t2, $t2, 24
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bot
			sb	$t7, ($t2)
			addi	$t2, $t2, -24
			beq	$t0, $t1, fullBombs
			j	bomb_loop
		
		bottom_rowMiddle:				#if in middle of bottom row, then bowxes to right, top right, top, top left, left
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase left
			sb	$t7, ($t2)
			addi	$t2, $t2, -28
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increae top left
			sb	$t7, ($t2)
			addi	$t2, $t2, 28
			addi	$t2, $t2, 8
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase right
			sb	$t7, ($t2)
			addi	$t2, $t2, -28
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top right
			sb	$t7, ($t2)
			addi	$t2, $t2, 28
			addi	$t2, $t2, -32
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top
			sb	$t7, ($t2)
			addi	$t2, $t2, 32
			beq	$t0, $t1, fullBombs
			j	bomb_loop
					
		left_columnMiddle:				#if in middle of left column then boxes to right, top right, top, bottom, bottom right
			addi	$t2, $t2, 4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase right
			sb	$t7, ($t2)
			addi	$t2, $t2, -32
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increae top
			sb	$t7, ($t2)
			addi	$t2, $t2, 4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top right
			sb	$t7, ($t2)
			addi	$t2, $t2, -4
			addi	$t2, $t2, 56
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bottom
			sb	$t7, ($t2)
			addi	$t2, $t2, 4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bottom right
			sb	$t7, ($t2)
			addi	$t2, $t2, -4
			addi	$t2, $t2, -24
			beq	$t0, $t1, fullBombs
			j	bomb_loop
					
		right_columnMiddle:				#if in middle of right column then boxes to left, top left, top, bottom, bottom left
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase left
			sb	$t7, ($t2)
			addi	$t2, $t2, -24
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top
			sb	$t7, ($t2)
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top left
			sb	$t7, ($t2)
			addi	$t2, $t2, 4
			addi	$t2, $t2, 56
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bottom 
			sb	$t7, ($t2)
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bottom left
			sb	$t7, ($t2)
			addi	$t2, $t2, 4
			addi	$t2, $t2, -24
			beq	$t0, $t1, fullBombs
			j	bomb_loop
					
		middle:						#if in the middle then boxes to left, top left, top, top right, right, bottom right, bottom, and bottom left get incremented by one
			addi	$t2, $t2, -4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase left
			sb	$t7, ($t2)		
			addi	$t2, $t2, 8
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase right
			sb	$t7, ($t2)
			addi	$t2, $t2, 24
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bottom 
			sb	$t7, ($t2)
			addi	$t2, $t2, 4
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bottom right
			sb	$t7, ($t2)
			addi	$t2, $t2, -8
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase bottom left
			sb	$t7, ($t2)
			addi	$t2, $t2, 4
			addi	$t2, $t2, -56
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top
			sb	$t7, ($t2)
			addi	$t2, $t2, 4		
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top right
			sb	$t7, ($t2)
			addi	$t2, $t2, -8
			lb	$t7, ($t2)
			addi	$t7, $t7, 1			#increase top left
			sb	$t7, ($t2)
			addi	$t2, $t2, 4
			addi	$t2, $t2, 32			#recenter pointer
			beq	$t0, $t1, fullBombs
			j	bomb_loop
						
		alreadyBomb:				#if the location chosen to be a bomb is already a bomb, then the loop will just continue without doing anything
			addi	$t2, $t2, 4
			j 	bomb_loop
		
		fullBombs:				#14 bombs have been input into the array and so now the function may return as it has done it's job
		
	jr	$ra

#function to check user selected location's value in the array and then use that to print out the proper symbol
check_Space:
	move	$s5, $ra				#store return address since more functions will be used throughout this
	li	$t0, 0					#counter
	la	$t1, bombArray				#array of bombs
	la	$t4, checkArray				#array to check if this space has been checked
	loop_Check:
		lb	$t2, ($t1)			#store bytes of both arrays for when the counter does meet the requirements and advanced
		lb	$t5, ($t4)
		addi	$t0, $t0, 1			#add one to the counter until it is equal to $s6 which is the tracked location of where the user is hovering
		beq	$t0, $s6, spot_Found
		addi	$t1, $t1, 4			#if not at it, then increment arrays and loop again
		addi	$t4, $t4, 4
		j	loop_Check
		
	spot_Found:
		jal	white_Box			#draw a white box to set the canvas in case of marker
		bge	$t2, 9, bomb_SymbolJAL		#if value is greater than 9, then it is a bomb and will be printed
		bgt	$t5, 0, continueFound		#$t5 is a value of the array checker. if it is 0, this has not been checked before. if it is 1, it has been checked before.
			addi	$s2, $s2, -1		#if not checked before, then it will take away 1 from the 35 squares to be found and store away a one in the array checkers value
			li	$t9, 1			#this is done to prevent a bug from occuring where a player will repeatedly 'check' the same space until they win
			sb	$t9, ($t4)
		continueFound:				#if value is less than 9, it is not a bomb and instead has x bombs directly next to it. that number is printed
		beq	$t2, 8, eight_BombsJAL			
		beq	$t2, 7, seven_BombsJAL
		beq	$t2, 6, six_BombsJAL
		beq	$t2, 5, five_BombsJAL
		beq	$t2, 4, four_BombsJAL
		beq	$t2, 3, three_BombsJAL
		beq	$t2, 2, two_BombsJAL
		beq	$t2, 1, one_BombJAL
		beq	$t2, 0, zero_BombsJAL
		
	bomb_SymbolJAL:					#print bomb
	j	bomb_Symbol
	j	end_Check
	eight_BombsJAL:					#print 8
	jal	eight_Bombs
	beq	$s2, 0, game_Win			#$s2 counts down from the number of safe tiles which begins at 35. Once it gets to 0, then all tiles have been discovered and user wins
	j	end_Check
	seven_BombsJAL:					#print 7
	jal	seven_Bombs
	beq	$s2, 0, game_Win
	j	end_Check
	six_BombsJAL:					#print 6
	jal	six_Bombs
	beq	$s2, 0, game_Win
	j	end_Check
	five_BombsJAL:					#print 5
	jal	five_Bombs
	beq	$s2, 0, game_Win
	j	end_Check
	four_BombsJAL:					#print 4
	jal	four_Bombs
	beq	$s2, 0, game_Win
	j	end_Check
	three_BombsJAL:					#print 3
	jal	three_Bombs
	beq	$s2, 0, game_Win
	j	end_Check
	two_BombsJAL:					#print 2
	jal	two_Bombs
	beq	$s2, 0, game_Win
	j	end_Check
	one_BombJAL:					#print 1
	jal	one_Bomb
	beq	$s2, 0, game_Win
	j	end_Check
	zero_BombsJAL:					#print 0
	jal	zero_Bombs
	beq	$s2, 0, game_Win
	j	end_Check
		
	end_Check:
		jr	$s5

#function to place a marker where the user thinks a bomb is
place_Marker:
	addi 	$a2, $0, YELLOW				#set color to yello
	move	$s7, $s1				#save pointer location to go back to later for movement purposes
	addi	$s1, $s1, 4				#move into the box
	addi	$s1, $s1, 256
	li	$t8, 0					#start counter
	marker_Loop:					#print all yellow in the box using this loop with the counter
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$t8, $t8, 1
		beq	$t8, 8, marker_Placed
		addi	$s1, $s1, 228
		j	marker_Loop
		
	marker_Placed:					#after the yellow box has been placed, then return to the original pointer location and return address
	move	$s1, $s7
	jr	$ra

#function to print a white box in a bomb symbol location in case a marker is changed
white_Box:
	addi 	$a2, $0, WHITE				#set color to white
	move	$s7, $s1				#save pointer location to go back to later for movement purposes
	addi	$s1, $s1, 4				#move into the box
	addi	$s1, $s1, 256
	li	$t8, 0					#start counter
	whiteBox_Loop:					#print all white in the box using this loop with the counter
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$s1, $s1, 4
		sw	$a2, 0($s1)
		addi	$t8, $t8, 1
		beq	$t8, 8, whiteBox_Placed
		addi	$s1, $s1, 228
		j	whiteBox_Loop
		
	whiteBox_Placed:				#after the white box has been placed, then return to the original pointer location and return address
	move	$s1, $s7
	jr	$ra					

#if the user wins the game, then this function is called			
game_Win:
	jal	show_Bombs				#first show the user they were correct by showing all of the symbols 
	jal	black_Screen				#next  use black screen function which sets the background to the base color which changed to white instead of black
	addi 	$a2, $0, 0				#set color to black
	add	$s1, $0, $gp				#set pointer to 0,0
	addi	$s1, $s1, 5460				#go to desired place to begin printing first word
	jal	y					#use functions to print YOU
	jal	o
	jal	u
	addi	$s1, $s1, 2464				#move to desired place for second word
	jal	w					#use functions to print WON
	jal	o
	jal	n
	addi	$s1, $s1, 2992				#move to desired place for face
	jal	smile					#use function to print smiley face
	
	j	end					#end the game
			
#function to show end screen for when the user loses		
end_ScreenLoss: 
	jal	black_Screen				#first use black screen function which sets the background to the base color which changed to white instead of black
	addi 	$a2, $0, 0				#set color to black
	add	$s1, $0, $gp				#set pointer to 0,0
	addi	$s1, $s1, 5460				#go to desired place to begin printing first word
	jal	y					#use functions to print YOU
	jal	o
	jal	u
	addi	$s1, $s1, 2468				#move to desired place for second word
	jal	l					#use functions to print LOST
	jal	o
	jal	s
	jal	t
	addi	$s1, $s1, 2988				#move to desired place for face
	jal	frown					#use function to print frowny face
	
	j	end					#end the game

#function to show bombs at the end of a game so the player knows what they did wrong. it also looks cool
show_Bombs:
	addi	$s0, $s0, 1				#add to gamestate counter making it 2. this means the point where pixels are being generated can no longer be moved by the user. 
	move	$a3, $ra				#store the return register since $ra will be changed in jal functions used within this function
	li	$t9, 7					#divisor for modulus division to know when at the end of a row
	add	$s1, $0, $gp				#start the pixel pointer at 0,0
	addi	$a2, $0, WHITE				#color it white
	li	$t0, 0					#counter of number of bomb areas printed
	la	$t1, bombArray				#address to bomb array
	loop_Bombs:	
		lb	$t2, ($t1)			#load byte from array
		addi	$t0, $t0, 1			#this will be printed so add to number of bomb areas printed
		addi	$t1, $t1, 4			#go to next byte in array for loop around
		print_Bomb:
		jal	white_Box			#print white box to have new canvas to work on. gets rid of markers and numbers/bombs
		bge	$t2, 9, bomb_SymbolJAL2		#if number is above 8 at this point in array, then it is a bomb and will be printed as such
		print_Numbers:
		beq	$t2, 8, eight_BombsJAL2		#if the number is less than 9, then it is the number of bombs directly around it and will  be printed out
		beq	$t2, 7, seven_BombsJAL2
		beq	$t2, 6, six_BombsJAL2
		beq	$t2, 5, five_BombsJAL2
		beq	$t2, 4, four_BombsJAL2
		beq	$t2, 3, three_BombsJAL2
		beq	$t2, 2, two_BombsJAL2
		beq	$t2, 1, one_BombJAL2
		beq	$t2, 0, zero_BombsJAL2
	
	#print bomb. use this for reference for next 9 functions if logic is to be tweaked
	bomb_SymbolJAL2:
	jal	bomb_Symbol_No_Loss			#print the desired symbol. this is lossless because it is after the game is over and would cause bugs if it was nomral bomb_Symbol
	
	li	$v0, 32					#stall for 100ms to create effect of each symbol being printed out 1 after the other
	la	$a0, 100
	syscall
	
	beq	$t0, 49, finishBombPrint		#if counter of bomb areas printed is at 49, then all areas have been printed
	
	div	$t0, $t9				#otherwise check to see at end of row. div the counter by the 7 held in $t9
	mfhi	$t3					#take the modulus value of this
	beq	$t3, 0, nextRow				#if equal to 0, then must go to next row
	
	addi	$s1, $s1, 36				#otherwise, just add 36 pixels to get to next bomb area
	j	sameRow					#loop past next_row since $t0 % 7 is not at 0
	
	nextRow:					#moves to next bomb area that is on next row
		addi	$s1, $s1, 40
		addi	$s1, $s1 2048
	
	sameRow:					#loops for the next bomb array value
		j	loop_Bombs
	
	#print 8
	eight_BombsJAL2:
	jal	eight_Bombs
	li	$v0, 32
	la	$a0, 100
	syscall
	beq	$t0, 49, finishBombPrint
	div	$t0, $t9
	mfhi	$t3
	beq	$t3, 0, nextRow2
	addi	$s1, $s1, 36
	j	sameRow2
	nextRow2:
	addi	$s1, $s1, 40
	addi	$s1, $s1 2048
	sameRow2:
	j	loop_Bombs
	
	#print 7
	seven_BombsJAL2:
	jal	seven_Bombs
	li	$v0, 32
	la	$a0, 100
	syscall
	beq	$t0, 49, finishBombPrint
	div	$t0, $t9
	mfhi	$t3
	beq	$t3, 0, nextRow3
	addi	$s1, $s1, 36
	j	sameRow3
	nextRow3:
	addi	$s1, $s1, 40
	addi	$s1, $s1 2048
	sameRow3:
	j	loop_Bombs
	
	#print 6
	six_BombsJAL2:
	jal	six_Bombs
	li	$v0, 32
	la	$a0, 100
	syscall
	beq	$t0, 49, finishBombPrint
	div	$t0, $t9
	mfhi	$t3
	beq	$t3, 0, nextRow4
	addi	$s1, $s1, 36
	j	sameRow4
	nextRow4:
	addi	$s1, $s1, 40
	addi	$s1, $s1 2048
	sameRow4:
	j	loop_Bombs
	
	#print 5
	five_BombsJAL2:
	jal	five_Bombs
	li	$v0, 32
	la	$a0, 100
	syscall
	beq	$t0, 49, finishBombPrint
	div	$t0, $t9
	mfhi	$t3
	beq	$t3, 0, nextRow5
	addi	$s1, $s1, 36
	j	sameRow5
	nextRow5:
	addi	$s1, $s1, 40
	addi	$s1, $s1 2048
	sameRow5:
	j	loop_Bombs
	
	#print 4
	four_BombsJAL2:
	jal	four_Bombs
	li	$v0, 32
	la	$a0, 100
	syscall
	beq	$t0, 49, finishBombPrint
	div	$t0, $t9
	mfhi	$t3
	beq	$t3, 0, nextRow6
	addi	$s1, $s1, 36
	j	sameRow6
	nextRow6:
	addi	$s1, $s1, 40
	addi	$s1, $s1 2048
	sameRow6:
	j	loop_Bombs
	
	#print 3
	three_BombsJAL2:
	jal	three_Bombs
	li	$v0, 32
	la	$a0, 100
	syscall
	beq	$t0, 49, finishBombPrint
	div	$t0, $t9
	mfhi	$t3
	beq	$t3, 0, nextRow7
	addi	$s1, $s1, 36
	j	sameRow7
	nextRow7:
	addi	$s1, $s1, 40
	addi	$s1, $s1 2048
	sameRow7:
	j	loop_Bombs
	
	#print 2
	two_BombsJAL2:
	jal	two_Bombs
	li	$v0, 32
	la	$a0, 100
	syscall
	beq	$t0, 49, finishBombPrint
	div	$t0, $t9
	mfhi	$t3
	beq	$t3, 0, nextRow8
	addi	$s1, $s1, 36
	j	sameRow8
	nextRow8:
	addi	$s1, $s1, 40
	addi	$s1, $s1 2048
	sameRow8:
	j	loop_Bombs
	
	#print 1
	one_BombJAL2:
	jal	one_Bomb
	li	$v0, 32
	la	$a0, 100
	syscall
	beq	$t0, 49, finishBombPrint
	div	$t0, $t9
	mfhi	$t3
	beq	$t3, 0, nextRow9
	addi	$s1, $s1,36
	j	sameRow9
	nextRow9:
	addi	$s1, $s1, 40
	addi	$s1, $s1 2048
	sameRow9:
	j	loop_Bombs
	
	#print 0
	zero_BombsJAL2:
	jal	zero_Bombs
	li	$v0, 32
	la	$a0, 100
	syscall
	beq	$t0, 49, finishBombPrint
	div	$t0, $t9
	mfhi	$t3
	beq	$t3, 0, nextRow10
	addi	$s1, $s1, 36
	j	sameRow10
	nextRow10:
	addi	$s1, $s1, 40
	addi	$s1, $s1 2048
	sameRow10:
	j	loop_Bombs
	
	#after it has all been printed, stall for 1 full second to allow the user to process, and the return the register
	finishBombPrint:
	
	li	$v0, 32
	la	$a0, 1000
	syscall
	
	jr	$a3	

##draw bomb symbol in pixels but force loss mechanism
bomb_Symbol:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 12
	addi	$s1, $s1, 512
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -8
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	move	$s1, $s7
	
	li	$v0, 32
	la	$a0, 500
	syscall
	jal	show_Bombs
	j	end_ScreenLoss
	jr	$ra

##draw bomb symbol in pixels but don't force loss mechanism
bomb_Symbol_No_Loss:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 12
	addi	$s1, $s1, 512
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -8
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	move	$s1, $s7

	jr	$ra

#draw 0 in pixels
zero_Bombs:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 12
	addi	$s1, $s1, 512
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	
	move	$s1, $s7
	
	jr	$ra

#draw 1 in pixels			
one_Bomb:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 16
	addi	$s1, $s1, 512
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -8
	sw	$a2, 0($s1)	
	
	move	$s1, $s7
	
	jr	$ra

#draw 2 in pixels	
two_Bombs:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 12
	addi	$s1, $s1, 512
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	
	move	$s1, $s7
	
	jr	$ra
	
#draw 3 in pixels
three_Bombs:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 8
	addi	$s1, $s1, 512
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 8
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	
	move	$s1, $s7
	
	jr	$ra
	
#draw 4 in pixels
four_Bombs:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 8
	addi	$s1, $s1, 512
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 768
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	
	move	$s1, $s7
	
	jr	$ra
	
#draw 5 in pixels
five_Bombs:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 24
	addi	$s1, $s1, 512
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	
	
	move	$s1, $s7
	
	jr	$ra
	
#draw 6 in pixels
six_Bombs:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 24
	addi	$s1, $s1, 512
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)	
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	move	$s1, $s7
	
	jr	$ra

#draw 7 in pixels
seven_Bombs:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 12
	addi	$s1, $s1, 768
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)	
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	
	move	$s1, $s7
	
	jr	$ra

#draw 8 in pixels
eight_Bombs:
	addi 	$a2, $0, 0
	move	$s7, $s1
	addi	$s1, $s1, 12
	addi	$s1, $s1, 512
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	
	move	$s1, $s7
		
	jr	$ra

#draw frown in pixels
frown:
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 36
	sw	$a2, 0($s1)
	addi	$s1, $s1, 2572
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	
	jr	$ra
	
#draw smile in pixels
smile:
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 36
	sw	$a2, 0($s1)
	addi	$s1, $s1, 1804
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)

	jr	$ra

#draw a in pixels
a:
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	move	$s7, $s1
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move	$s1, $s7
	add	$s1, $s1, 256
	sw	$a2, 0($s1)
	add	$s1, $s1, 16
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	
	addi	$s1, $s1, 12
	
	jr	$ra

#draw e in pixels
e:
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	addi	$s1, $s1, 256
	addi	$s1, $s1, 240
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	addi	$s1, $s1, 256
	addi	$s1, $s1, 244
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 12

	jr	$ra

#draw i in pixels
i:
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move	$s7, $s1
	addi	$s1, $s1, -264
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -8
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 8
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move 	$s1, $s7
	addi	$s1, $s1, 12
	
	jr	$ra

#draw l in pixels
l:
	addi 	$a2, $0, 0
	sw	$a0, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 1540
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 12
	
	jr	$ra
	
#draw m in pixels
m:
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 12
	
	jr	$ra
	
#draw n in pixels
n:
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	move	$s7, $s1
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	move 	$s1, $s7
	addi	$s1, $s1, 12
	
	jr	$ra
	
#draw o in pixels
o:
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	move	$s7, $s1
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 12

	jr	$ra
	
#draw p in pixels
p:
	move	$s7, $s1
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 28

	jr	$ra

#draw r in pixels
r:
		sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 12
	
	jr	$ra
	
#draw s in pixels
s:
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move 	$s7, $s1
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move 	$s1, $s7
	addi	$s1, $s1, 12

	jr	$ra
	
#draw t in pixels
t:
	addi	$s1, $s1, 8
	sw	$a2, 0($s1)
	move	$s7, $s1
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -8
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 8
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 20
	
	jr	$ra
	
#draw u in pixels
u:
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 1540
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move	$s7, $s1
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 16
	
	jr	$ra

#draw w in pixels
w:
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 1284
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)	
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	move 	$s7, $s1
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 12
			
	jr	$ra

#draw y in pixels
y:
	addi	$s1, $s1, 8
	sw	$a2, 0($s1)
	move	$s7, $s1
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -8
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 16
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -16
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 20

	jr	$ra
	
#draw opening angle bracket in pixels
angle_bracketOpen:
	addi	$s1, $s1, -768
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 512
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -1024
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 1536
	sw	$a2, 0($s1)
	addi	$s1, $s1, 12
	
	jr	$ra	

#draw closing angle bracket in pixels
angle_bracketClose:
	move	$s7, $s1
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -252
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 24
	
	jr	$ra
	
#draw mdb190007 in pixels
mdb190007:
	#draw m in pixels
	thisM:
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1,-252
	sw	$a2, 0($s1)
	addi	$s1, $s1,-252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 8
	
	#draw d in pixels
	thisD:
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 12
	
	#draw b in pixels
	thisB:
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 260
	sw	$a2, 0($s1)
	addi	$s1, $s1, 252
	sw	$a2, 0($s1)
	addi	$s1, $s1, 12
	
	#draw 1 in pixels
	this1:
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move	$s7, $s1
	addi	$s1, $s1, -260
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 8
	
	#draw 9 in pixels
	this9:
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move	$s7, $s1
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 8
	
	#draw 3 0's in pixels 
	li	$t1, 0
	this0:
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 4
	sw	$a2, 0($s1)
	move	$s7, $s1
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	move	$s1, $s7
	addi	$s1, $s1, 8
	addi	$t1, $t1, 1
	beq	$t1, 3, this7
	j	this0
	
	#draw 7 in pixels
	this7:
	addi	$s1, $s1, 8
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -256
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, -4
	sw	$a2, 0($s1)
	addi	$s1, $s1, 256
	sw	$a2, 0($s1)
	
	jr	$ra	