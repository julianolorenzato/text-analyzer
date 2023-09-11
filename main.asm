.data
char_buffer: .byte 0
chars_counter:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 # uppercase letters
	.space 6 # non letters gap
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 # lowercase letters
menu_msg: .asciiz "O que deseja saber?\n(1)Contagem de palavras (2)Contagem de letras (3)Frequência de cada letra (4)Sair\n"
word_msg: .asciiz " palavras no texto\n"
char_msg: .asciiz " letras no texto\n"
filename: .asciiz "input.txt"

.text
main:
	jal open_file
	move $s0, $v0 # s0 = file descriptor
	jal menu
	li $s1, 1
	li $s2, 2
	li $s3, 3
	li $s4, 4
	beq $v0, $s1, words_count
	beq $v0, $s2, chars_count
	beq $v0, $s3, chars_frequency
	beq $v0, $s4, hault
	j main
	
words_count:
	li $t0, 1 # word counter
	read_loop:
		# read next chat
		li $v0, 14
		move $a0, $s0
		la $a1, char_buffer
		li $a2, 1
		syscall
		
		beqz $v0, eof_wc
		
		lb $t1, char_buffer # $t1 = the byte that was read
		beq $t1, 32, increment_wc
		
		j read_loop

	increment_wc:
		addiu $t0, $t0, 1
		j read_loop
		
	eof_wc:
		li $v0, 1
		move $a0, $t0
		syscall
		
		li $v0, 4
		la $a0, word_msg
		syscall
		
		jal close_file
		j main

chars_count:
	li $t0, 0
	loop_cc:
		# read next char
		li $v0, 14
		move $a0, $s0
		la $a1, char_buffer
		li $a2, 1
		syscall
		
		lb $t1, char_buffer
		
		beq $t1, 32, loop_cc # if space was read skip this iteration
		beqz $v0, eof_cc
		
		addiu $t0, $t0, 1 # increment char counter
		j loop_cc
	eof_cc:	
		addi $t0, $t0, -1
	
		li $v0, 1
		move $a0, $t0
		syscall
		
		li $v0, 4
		la $a0, char_msg
		syscall
		
		jal close_file
		j main

chars_frequency:
	li $t0, 0
	li $t1, 58
	la $t2, chars_counter
	loop_clear:
		sb $zero, 0($t2)
		addi $t0, $t0, 1
		addi $t2, $t2, 1
		bne $t0, $t1, loop_clear

	loop:
		# read next char
		li $v0, 14 # syscall code to read from file
		move $a0, $s0 # file descriptor
		la $a1, char_buffer # address of buffer
		li $a2, 1 # number of max chars to read
		syscall
		
		beq $v0, $zero, eof # if reaches EOF (0 char was read) break the loop
	
		lb $t0, char_buffer # load byte from buffer
		beq $t0, 32, loop # if space was read skip this iteration
	
		addi $t0, $t0, -65
		
		la $t1, chars_counter
		addu $t1, $t1, $t0
		
		lb $t2, 0($t1)
		addu $t2, $t2, 1
		
		sb $t2, 0($t1)
		
		# print char that was read
		li $v0, 11
		lb $a0, char_buffer
		syscall
	
		j loop
	
	eof:
		li $t0, 0
		li $t1, 25
		loop_print:
			# print the uppercase letter
			li $v0, 11,
			addi $a0, $t0, 65
			syscall
			
			# print space
			li $a0, 32
			syscall
			
			# print frequency of uppercase letter
			li $v0, 1
			la $t2, chars_counter
			addu $t2, $t2, $t0
			lb $a0, 0($t2)
			syscall
			
			# print pipe
			li $v0, 11
			li $a0, 124
			syscall
			
			# print lowercase letter
			addi $a0, $t0, 97
			syscall
			
			# print space
			li $a0, 32
			syscall
			
			# print frequency of lowercase letter
			li $v0, 1
			la $t2, chars_counter
			addu $t2, $t2, $t0
			addi $t2, $t2, 32
			lb $a0, 0($t2)
			syscall
			
			# print new line
			li $v0, 11
			li $a0, 10
			syscall
			
			addi, $t0, $t0, 1
			bne $t0, $t1, loop_print
		
		jal close_file
		j main

open_file:
	li $v0, 13, # syscall code to open file
	la $a0, filename
	li $a1, 0 # flag mode = 0 (read)
	syscall
	
	jr $ra
	
close_file:
	li $v0, 16 # syscall code to close file
	move $a0, $s0 # file descriptor
	syscall
	
	jr $ra

menu:
	li $v0, 4 # syscall code to print string
	la $a0, menu_msg
	syscall
	
	li $v0, 5 # syscall code to read integer, it goes to $v0
	syscall
	
	jr $ra

# terminates the program
hault:
	li $v0, 10
	syscall
