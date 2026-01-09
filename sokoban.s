# a) Enhancement 1: Multiplayer

# b) Can be found on line 161 in the multiplayer_game_loop.
# Scoreboard is dealt with on line 679 in rank. The functions sort_leaderboard and
# print_leaderboard are called.

# c) Implentation: Based on user input, the number of players playing is stored in static memory
# where its labelled num_players. The program then enters multiplayer_game_loop and loops through
# this num_players times. Therefore, there are num_players games played. There is an inner loop
# called game_loop. In the inner loop, the program waits for user input in order to make a move.
# In the multiplayer_game_loop the number of moves each player makes, for their respective game,
# is stored in register s10. At the end of each player's game, the number of moves they made is
# stored in the heap and the register s10 is reset to 0 for the next player's game. At the end
# of the round, we need to print the scoreboard. This is done by accessing the heap which has the
# stored number of moves made by each player. Then, store the player number on the heap and keep
# track of which moves belong to which player. The program then calls the function sort_leaderbaord
# which sorts the moves and the player numbers based on their moves by using bubble sort. Finally,
# call the function print_leaderboard which prints the scoreboard by iterating over the sorted
# moves on heap.

# a) Enhancement 2: Infinite Replay

# b) Can be found on line 746 in replay. The function print_replay is called.

# c) Implementation: A heap pointer is stored in register s11 and in static memory labelled heap2.
# Throughout the game_loop, whenever the player makes a move, the player and box coordinates
# are stored on the heap. The heap pointer in s11 is incremented. After the scoreboard is printed,
# the program goes into where its labelled replay. Based on user input, the program figures out
# the offset for heap2 to access the correct section where the respective players moves are stored.
# This offset is calculated by entering a loop and getting the number of moves for each player up 
# to the chosen player from the heap. Then adding this to the heap2 pointer. After that, the 
# initial coordinates of box and character are restored and the function print_replay is called.
# In this function, the program enters a loop and iterates through the moves in heap2, updates 
# the coordinates and prints the gameboard. It waits for user input to print the next replayed move.

.data
gridsize:   .byte 3,3	# Adjust boardsize here	
character:  .byte 0,0
box:        .byte 0,0
target:     .byte 0,0

# The citations to the Linear Congruential Generator Algorithm are below:

# Thomson, W. E. (1958). A modified congruence method of generating pseudo-random numbers. 
# The Computer Journal, 1(2), 83–83. https://doi.org/10.1093/comjnl/1.2.83 

# GeeksforGeeks. (2021, July 17). Linear congruence method for generating pseudo random numbers. 
# https://www.geeksforgeeks.org/linear-congruence-method-for-generating-pseudo-random-numbers/ 

seed: 		.word 0	# S0

border_str:		.string "# "
space_str:		.string ". "
character_str:	.string "i "
box_str:		.string "X "
target_str:		.string "* "
new_line:		.string "\n"
prompt:			.string "\nMake Move (w, a, s, d):\n"
invalid_move:	.string "Invalid Move! Please try again\n\n"
invalid_input:	.string "Invalid Input! Please try again\n\n"
win:			.string "\nYOU WIN!!!\n"
restart:		.string "\nPress r to restart game\n"
next:		.string "\nPress n to continue\n"
anything:	.string "Press any key to continue\n"
how_many_players: .string "How many players are playing?\n"
player:			.string "Player "
replay_prompt:	.string "\nEnter the Player number you want to replay moves for\nOtherwise, enter anything else to skip replays\n"
scoreboard:	.string "SCOREBOARD:\n"

# this is to save the original locations for multiplayer and infinite replay
save_character:	.byte 0,0
save_box:		.byte 0,0
save_target:	.byte 0,0

num_players:	.byte 0
.align 4
heap:			.word 0
.align 4
heap2:			.word 0

.text
.globl _start

_start:
	
	# seed Address for LCG saved in S0 (DO NOT MODIFY)
	la s0, seed
	li a7, 30
	ecall
	sw a0, 0(s0)
	
	la t0, gridsize
	lb s1, 0(t0)		# x-size of board saved in S1
	lb s2, 1(t0)		# y-size of board saved in S2
	
	la s3, new_line
	la s4, border_str
	la s5, space_str
	la s6, character_str
	la s7, box_str
	la s8, target_str
	
	li sp, 0x80000000
	li t0, 0x10000000
	la t1, heap
	sw t0, 0(t1)
	li s11, 0x40000000
	la t1, heap2
	sw s11, 0(t1)		# s11 keeps track of infinite replay coordinates
	
	number_players_prompt:
		la a0, how_many_players
		li a7, 4
		ecall

		li a7, 5
		ecall
		
		li t0, 1
		bge a0, t0, number_players_prompt_done
		
		la a0, invalid_input
		li a7, 4
		ecall
		
		j number_players_prompt
	number_players_prompt_done:
	
	la t0, num_players
	sb a0, 0(t0)
	
	jal ra, generate_locations		# randomly generates start locations
	
	# saving all the start locations in static memory
	la t0, save_character
	la t1, character
	lb t2, 0(t1)
	sb t2, 0(t0)
	lb t2, 1(t1)
	sb t2, 1(t0)
	
	la t0, save_box
	la t1, box
	lb t2, 0(t1)
	sb t2, 0(t0)
	lb t2, 1(t1)
	sb t2, 1(t0)
	
	la t0, save_target
	la t1, target
	lb t2, 0(t1)
	sb t2, 0(t0)
	lb t2, 1(t1)
	sb t2, 1(t0)
	
	li s9, 1	# s9 is the player number counter
	mv a0, s3
	li a7, 4
	ecall		# prints new line
	
multiplayer_game_loop:
	li s10, 0			# s10 keeps track of number of moves for this player
	
	la t0, num_players
	lb t0, 0(t0)
	addi t0, t0, 1
	beq t0, s9, rank
	
	la a0, player
	li a7, 4
	ecall
	
	mv a0, s9
	li a7, 1
	ecall
	
	mv a0, s3
	li a7, 4
	ecall
	
	mv a0, s3
	li a7, 4
	ecall
	
	la t0, character
	la t1, save_character
	lb t2, 0(t1)
	sb t2, 0(t0)
	lb t2, 1(t1)
	sb t2, 1(t0)
	
	la t0, box
	la t1, save_box
	lb t2, 0(t1)
	sb t2, 0(t0)
	lb t2, 1(t1)
	sb t2, 1(t0)
	
	la t0, target
	la t1, save_target
	lb t2, 0(t1)
	sb t2, 0(t0)
	lb t2, 1(t1)
	sb t2, 1(t0)
	
	game_loop:
		jal ra, print_gameboard
		
		la a0, prompt
		li a7, 4
		ecall
		
		li a7, 12
		ecall
		
		mv t1, a0	# stores user input in t1
		
		mv a0, s3
		li a7, 4
		ecall		# prints new line
		
		mv a0, s3
		li a7, 4
		ecall		# prints new line
		
		li t0, 'w'
		beq t1, t0, move_up
		
		li t0, 'a'
		beq t1, t0, move_left
		
		li t0, 's'
		beq t1, t0, move_down
		
		li t0, 'd'
		beq t1, t0, move_right
		
		li t0, 'r'
		beq t1, t0, reset_heap2
		
		la a0, invalid_input
		li a7, 4
		ecall
	
		j game_loop
		
	reset_heap2:
		slli t0, s10, 2
		sub s11, s11, t0
		j multiplayer_game_loop
		
	move_up:
		la t0, character
		lb t1, 1(t0)
		addi t1, t1, -1
		
		blt t1, zero, move_invalid		# if new y is less than 0
		
		la t2, box
		lb t3, 1(t2)
		
		beq t1, t3, move_check_box_up
		
		sb t1, 1(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
		
		j game_loop
	
	move_down:
		la t0, character
		lb t1, 1(t0)
		addi t1, t1, 1
		
		bge t1, s2, move_invalid	# if new y is greater thah gridsize
		
		la t2, box
		lb t3, 1(t2)
		
		beq t1, t3, move_check_box_down
		
		sb t1, 1(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
		
		j game_loop
	
	move_left:
		la t0, character
		lb t1, 0(t0)
		addi t1, t1, -1
		
		blt t1, zero, move_invalid	# if new x is less than 0
		
		la t2, box
		lb t3, 0(t2)
		
		beq t1, t3, move_check_box_left
		
		sb t1, 0(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
		
		j game_loop
	
	move_right:
		la t0, character
		lb t1, 0(t0)
		addi t1, t1, 1
		
		bge t1, s1, move_invalid 	# if new x is greater thah gridsize
		
		la t2, box
		lb t3, 0(t2)
		
		beq t1, t3, move_check_box_right
		
		sb t1, 0(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
		
		j game_loop
		
	move_invalid:
		la a0, invalid_move
		li a7, 4
		ecall
	
		j game_loop
		
	move_check_box_up:
		lb t4, 0(t0)
		lb t5, 0(t2)
		
		beq t4, t5, move_box_up
		
		sb t1, 1(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
		
		j check_win
		
	move_box_up:
		addi t3, t3, -1
		
		blt t3, zero, move_invalid		# if new box y is less than 0
		
		sb t3, 1(t2)
		sb t1, 1(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
	
		j check_win
		
	move_check_box_down:
		lb t4, 0(t0)
		lb t5, 0(t2)
		
		beq t4, t5, move_box_down
		
		sb t1, 1(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
		
		j check_win
		
	move_box_down:
		addi t3, t3, 1
		
		bge t3, s2, move_invalid	# if new y is greater than gridsize
		
		sb t3, 1(t2)
		sb t1, 1(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
	
		j check_win
		
	move_check_box_left:
		lb t4, 1(t0)
		lb t5, 1(t2)
		
		beq t4, t5, move_box_left
		
		sb t1, 0(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
		
		j check_win
		
	move_box_left:
		addi t3, t3, -1
		
		blt t3, zero, move_invalid		# if new box x is less than 0
		
		sb t3, 0(t2)
		sb t1, 0(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
	
		j check_win
		
	move_check_box_right:
		lb t4, 1(t0)
		lb t5, 1(t2)
		
		beq t4, t5, move_box_right
		
		sb t1, 0(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
		
		j check_win
		
	move_box_right:
		addi t3, t3, 1
		
		bge t3, s1, move_invalid 	# if new x is greater thah gridsize
		
		sb t3, 0(t2)
		sb t1, 0(t0)
		addi s10, s10, 1
		
		############### This is how the moves are stored for infinite replay ################
		lb t6, 0(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t0)
		sb t6, 0(s11)
		addi s11, s11, 1
		la t2, box
		lb t6, 0(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		lb t6, 1(t2)
		sb t6, 0(s11)
		addi s11, s11, 1
		#####################################################################################
	
		j check_win
		
	check_win:
		la t0, target
		la t1, box
		
		lb t2, 0(t0)
		lb t3, 0(t1)
		bne t2, t3, game_loop
		
		lb t2, 1(t0)
		lb t3, 1(t1)
		bne t2, t3, game_loop
		
		jal ra, print_gameboard
		
		la a0, win
		li a7, 4
		ecall
		
		la t0, heap
		lw t1, 0(t0)
		sw s10, 0(t1)
		addi t1, t1, 4
		sw t1, 0(t0)
		
		la a0, next
		li a7, 4
		ecall
		
		li a7, 12
		ecall
		
		mv t1, a0
		
		mv a0, s3
		li a7, 4
		ecall		# prints new line
		
		mv a0, s3
		li a7, 4
		ecall
		
		li t0, 'n'
		beq t1, t0, game_done
	
	end:
		la a0, next
		li a7, 4
		ecall
		
		li a7, 12
		ecall
		
		mv t1, a0
		
		mv a0, s3
		li a7, 4
		ecall		
		
		mv a0, s3
		li a7, 4
		ecall
		
		li t0, 'n'
		beq t1, t0, game_done
		
		j end
		
game_done:
	addi s9, s9, 1
	j multiplayer_game_loop
	
	
rank:
	la t0, num_players
	lb t0, 0(t0)			# t0 = number of players
	
	li t1, 1
	beq t0, t1, rank_single_player
	
	slli t1, t0, 2
	
	la t2, heap
	lw t3, 0(t2)
	mv t4, t3
	
	sub t3, t3, t1			# t3 = base of moves = a0
	mv a0, t3
	
	li t5, 1
	addi t0, t0, 1	
	rank_num_players:
		sw t5, 0(t4)
		
		addi t4, t4, 4
		
		beq t5, t0, rank_num_players_done
		
		addi t5, t5, 1
		j rank_num_players
		
	rank_num_players_done:
		slli t5, t5, 2
		sub t4, t4, t5		# t4 = base of players = a1
		mv a1, t4

		addi a2, t0, -2		# a2 = num_players - 1

		jal ra, sort_leaderboard		# uses bubble sort to sort the heap
		jal ra, print_leaderboard		# prints the leader board
		
		j replay
	
	rank_single_player:				# if its single player, just print the leaderboard
		la a0, scoreboard
		li a7, 4
		ecall
		
		la a0, player
		li a7, 4
		ecall
		
		li a0, 1
		li a7, 1
		ecall                 # Print player number
		
		mv a0, s3
		li a7, 4
		ecall
		
		la t0, heap
		lw t0, 0(t0)
		lw a0, -4(t0)
		li a7, 1
		ecall                 # Print number of moves
		
		mv a0, s3
		li a7, 4
		ecall
	
	replay:
		la a0, replay_prompt
		li a7, 4
		ecall
		
		li a7, 5
		ecall
		
		beq a0, zero, restart_game
		
		blt a0, zero, restart_game
		
		la t0, num_players
		lb t0, 0(t0)
		blt a0, t0, replay_player
		beq a0, t0, replay_player
		
		la a0, invalid_input
		li a7, 4
		ecall
		
		j replay
		
		replay_player:
			li t1, 1
			beq t0, t1, replay_single_player
			
			j replay_loop_init
			replay_single_player:		# if its single player, no need to calculate offset
				la t3, heap2
				lw a0, 0(t3)		
				la t1, heap
				lw t1, 0(t1)
				lw a1, -4(t1)
				
				la t0, save_character
				la t1, character
				lb t2, 0(t0)
				sb t2, 0(t1)
				lb t2, 1(t0)
				sb t2, 1(t1)

				la t0, save_box
				la t1, box
				lb t2, 0(t0)
				sb t2, 0(t1)
				lb t2, 1(t0)
				sb t2, 1(t1)
				
				jal ra, print_replay
				
				j replay
			
			replay_loop_init:
			# a0 chosen player
			# t0 num_players
			# t3 heap2 pointer at start
			la t3, heap2
			lw t3, 0(t3)
			# t4 counter start at 1
			li t4, 1
		
			while_replay_player:
				# t1 heap pointer at the start of players
				la t1, heap
				lw t1, 0(t1)
				# t2 = 0x10000000 heap pointer at start
				li t2, 0x10000000
				
				while_inner_replay_player:
					lw t5, 0(t1)
					bne t5, t4, update_inner_replay_player
					
					lw t6, 0(t2)
					slli t5, t6, 2
					add t3, t3, t5
					
					li a6, 1
					beq a0, a6, fix_p1_offset
					
					j done_inner_replay_player
					
					update_inner_replay_player:
						addi t1, t1, 4
						addi t2, t2, 4
						
						j while_inner_replay_player
						
				done_inner_replay_player:
					addi t4, t4, 1
					bge t4, a0, done_while_replay_player
				
					j while_replay_player
					
				fix_p1_offset:
					sub t3, t3, t5
			
			done_while_replay_player:
				mv a1,a0
				mv a0, t3
				# now t3 which is heap2 pointer should be in the right place
				# lw t6, 4(t2) is the number of moves made by that player
				
					la t1, heap
					lw t1, 0(t1)
					# t2 = 0x10000000 heap pointer at start
					li t2, 0x10000000
				for_replay:
					lw t3, 0(t1)
					lw t4, 0(t2)
					slli t5, t4, 2
					
					beq a1, t3, for_replay_done
					
					addi t1, t1, 4
					addi t2, t2, 4
					
					j for_replay
				for_replay_done:
				
				lw t6, 0(t2)
				
				mv a1, t6
				
				la t0, save_character
				la t1, character
				lb t2, 0(t0)
				sb t2, 0(t1)
				lb t2, 1(t0)
				sb t2, 1(t1)

				la t0, save_box
				la t1, box
				lb t2, 0(t0)
				sb t2, 0(t1)
				lb t2, 1(t0)
				sb t2, 1(t1)
				
				jal ra, print_replay
		
			j replay
	
	restart_game:
		la a0, restart
		li a7, 4
		ecall
		
		li a7, 12
		ecall
		
		mv t1, a0
		
		mv a0, s3
		li a7, 4
		ecall		
		
		mv a0, s3
		li a7, 4
		ecall
		
		li t0, 'r'
		beq t1, t0, _start
		
		j restart_game

# --- HELPER FUNCTIONS ---
# Feel free to use, modify, or add to them however you see fit.

print_gameboard:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	mv t0, s1		# count down from these
	mv t1, s2
	
	addi sp, sp, -4
	sw s3, 0(sp)	# pushed '/n '
	
	addi t2, t0, 2
	while_bottom_border:
		addi sp, sp, -4
		sw s4, 0(sp)
		
		addi t2, t2, -1
		bne t2, zero, while_bottom_border	# push '##...#'
	
	while_y:
		addi sp, sp, -4
		sw s3, 0(sp)	# pushed '/n '
		addi sp, sp, -4
		sw s4, 0(sp)	# pushed '# '
		
		while_x:
			character_pos:
				la t2, character
				lb t3, 0(t2)
				addi t3, t3, 1
				bne t3, t0, box_pos
				lb t3, 1(t2)
				addi t3, t3, 1
				bne t3, t1, box_pos
				
				addi sp, sp, -4
				sw s6, 0(sp)
				
				j while_x_done
				
			box_pos:
				la t2, box
				lb t3, 0(t2)
				addi t3, t3, 1
				bne t3, t0, target_pos
				lb t3, 1(t2)
				addi t3, t3, 1
				bne t3, t1, target_pos
				
				addi sp, sp, -4
				sw s7, 0(sp)
				
				j while_x_done
			
			target_pos:
				la t2, target
				lb t3, 0(t2)
				addi t3, t3, 1
				bne t3, t0, space_pos
				lb t3, 1(t2)
				addi t3, t3, 1
				bne t3, t1, space_pos
				
				addi sp, sp, -4
				sw s8, 0(sp)
				
				j while_x_done
			space_pos:
				addi sp, sp, -4
				sw s5, 0(sp)
				
			while_x_done:
			
			addi t0, t0, -1
			beq t0, zero, done_x
			
			j while_x
		done_x:
		
		mv t0, s1
		
		addi sp, sp, -4
		sw s4, 0(sp)	# pushed '# '
		
		addi t1, t1, -1
		beq t1, zero, done_y
		
		j while_y
	done_y:
	
	addi sp, sp, -4
	sw s3, 0(sp)	# pushed '/n '
	
	addi t2, t0, 2
	while_top_border:
		addi sp, sp, -4
		sw s4, 0(sp)
		
		addi t2, t2, -1
		bne t2, zero, while_top_border	# push '##...#'
		
	print_stack:
		mv t0, s1
		addi t0, t0, 3
		mv t1, s2
		addi t1, t1, 2
		
		mul t0, t0, t1
		
		while_print_stack:
			lw a0, 0(sp)
			addi sp, sp, 4
			li a7, 4
			ecall
			
			addi t0, t0, -1
			bne t0, zero, while_print_stack
		
	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)

generate_locations:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	jal ra, generate_character_location	
	jal ra, generate_box_location
	jal ra, generate_target_location
	
	jal ra, check_box_valid
	jal ra, check_target_valid
		
	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)
	
generate_character_location:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	# Generates x-coordinate for character
	mv a0, s1
	jal LCG
	la t0, character
	sb a0, 0(t0)

	# Generates y-coordinate for character
	mv a0, s2
	jal LCG
	la t0, character
	sb a0, 1(t0)
	
	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)
	
generate_box_location:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	# Generates x-coordinate for box
	mv a0, s1
	jal LCG
	la t0, box
	sb a0, 0(t0)

	# Generates y-coordinate for box
	mv a0, s2
	jal LCG
	la t0, box
	sb a0, 1(t0)
	
	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)
		
generate_target_location:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	# Generates x-coordinate for target
	mv a0, s1
	jal LCG
	la t0, target
	sb a0, 0(t0)

	# Generates y-coordinate for box
	mv a0, s2
	jal LCG
	la t0, target
	sb a0, 1(t0)
	
	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)
	
check_box_valid:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	box_while:
		la t0, box
		lb t1, 0(t0)
		lb t2, 1(t0)
		
		addi t3, s1, -1
		addi t4, s2, -1
		
		beq t1, zero, set_target_left
		beq t2, zero, set_target_up
		
		beq t1, t3, set_target_right
		beq t2, t4, set_target_down
		
		j box_character
		
	set_target_left:
		la t0, target
		lb t1, 0(t0)
		
		bne t1, zero, call_target_gen
		
		j box_corner
		
	set_target_up:
		la t0, target
		lb t1, 1(t0)
		
		bne t1, zero, call_target_gen
		
		j box_corner
	
	set_target_right:
		la t0, target
		lb t1, 0(t0)
		
		bne t1, t3, call_target_gen
		
		j box_corner
	
	set_target_down:
		la t0, target
		lb t1, 1(t0)
		
		bne t1, t4, call_target_gen
		
		j box_corner
		
	call_target_gen:
		jal ra, generate_target_location
		
		j box_while
	
	box_character:
		la t0, box
		lb t1, 0(t0)
		lb t2, 1(t0)
		
		la t0, character
		lb t3, 0(t0)
		lb t4, 1(t0)

		bne t1, t3, box_done		# check if x vals are not equal
		bne t2, t4, box_done		# check if x vals are not equal

		jal ra, generate_character_location

		j box_while
	
	box_corner:
		la t0, box
		lb t1, 0(t0)
		lb t2, 1(t0)
		
		addi t3, s1, -1
		addi t4, s2, -1
		
		beq t1, zero, check_box_y
		beq t1, t3, check_box_y
		
		j box_character

		check_box_y:	# checking (0, 0), (0, n-1), (n-1, 0), (n-1, n-1)
			beq t2, zero, call_box_gen
			beq t2, t4, call_box_gen
			
			j box_character
		call_box_gen:
			jal ra, generate_box_location
			j box_while
			
	box_done:

	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)
	
check_target_valid:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	target_while:
		la t0, target
		lb t1, 0(t0)
		lb t2, 1(t0)
		
		la t0, character
		lb t3, 0(t0)
		lb t4, 1(t0)
		
		bne t1, t3, check_target_box		# check if x vals are not equal
		bne t2, t4, check_target_box		# check if x vals are not equal

		jal ra, generate_target_location
		jal ra, check_box_valid

		j target_while
		
	check_target_box:
		la t0, target
		lb t1, 0(t0)
		la t2, box
		lb t3, 0(t2)
		bne t1, t3, target_done
		
		lb t1, 1(t0)
		lb t3, 1(t2)
		bne t1, t3, target_done
		
		jal ra, generate_target_location
		jal ra, check_box_valid

		j target_while
		
	target_done:
	
	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)
	
sort_leaderboard:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	outer_loop:
		mv t0, zero
		mv t1, zero
			
		inner_loop:
			slli t2, t1, 2
			add t3, a0, t2
			lw t4, 0(t3)
			lw t5, 4(t3)

			blt t4, t5, skip_swap
			beq t4, t5, skip_swap

			sw t5, 0(t3)
			sw t4, 4(t3)

			add t6, a1, t2
			lw t4, 0(t6)
			lw t5, 4(t6)
			sw t5, 0(t6)
			sw t4, 4(t6)

			li t0, 1
			
		skip_swap:
			addi t1, t1, 1
			blt t1, a2, inner_loop
			bnez t0, outer_loop

	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)

# Arguments: pointer to heap in a0 and a1
#			 number of players - 1 in a2
print_leaderboard:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	mv t0, a0
	mv t1, a1
	mv t2, a2
	addi t2, t2, 1
	
	la a0, scoreboard
	li a7, 4
	ecall
	
	li t3, 0
	print_leaderboard_loop:
		la a0, player
		li a7, 4
		ecall
		
		slli t4, t3, 2        
		add t5, t1, t4        
		lw a0, 0(t5)          
		li a7, 1
		ecall                 # Print player number
		
		mv a0, s3
		li a7, 4
		ecall
		
		add t6, t0, t4        
		lw a0, 0(t6)          
		li a7, 1
		ecall                 # Print number of moves
		
		mv a0, s3
		li a7, 4
		ecall
		
		addi t3, t3, 1        # Increment loop index
    	blt t3, t2, print_leaderboard_loop  # Continue loop until t3 == num_players
	
	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)
	
# Arguments: heap2 pointer in a0
# 			 the number of moves for this player in a1
print_replay:
	addi sp, sp, -4
	sw ra, 0(sp)		# stores return adress on stack
	
	mv a5, a0
	mv a6, a1
	li a4, 0
	
	jal ra, print_gameboard
	
	mv a0, s3
	li a7, 4
	ecall
	
	la a0, anything
	li a7, 4
	ecall
	
	li a7, 12
	ecall
	
	mv a0, s3
	li a7, 4
	ecall
	
	print_replay_loop:
		addi a4, a4, 1
		
		la t0, character
		lb t1, 0(a5)
		sb t1, 0(t0)
		lb t1, 1(a5)
		sb t1, 1(t0)
		
		la t0, box
		lb t1, 2(a5)
		sb t1, 0(t0)
		lb t1, 3(a5)
		sb t1, 1(t0)
		
		jal ra, print_gameboard
		
		mv a0, s3
		li a7, 4
		ecall
		
		addi a5, a5, 4
		
		beq a4, a6, print_replay_done
		
		la a0, anything
		li a7, 4
		ecall

		li a7, 12
		ecall

		mv a0, s3
		li a7, 4
		ecall
		
		j print_replay_loop
		
	print_replay_done:
	
	lw ra, 0(sp)
	addi sp, sp, 4		# loads return adress from stack
	jalr zero, 0(ra)

	
# Arguments: an integer MAX in a0
# Return: A number from 0 (inclusive) to MAX (exclusive)
LCG:
	lw t0, 0(s0)	# s0 contains seed
	li t1, 214013	# a
	li t2, 2531011	# c the increment
	li t3, 0xefffffff # m
	
	mul t4, t0, t1	# seed * a
	add t4, t4, t2	# (seed * a) + c
	rem t4, t4, t3	# ((seed * a) + c) % m

	sw t4, 0(s0)	# new seed

	remu a0, t4, a0	# scale random number to range
	
	jr ra
