.data
char_buffer: .byte 0
chars_counter: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 # uppercase letters
.space 6 # non letters gap
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 # lowercase letters
menu_msg: .asciiz "O que deseja saber?\n(1)Frequência de cada palavra (2)Frequência de cada letra (3)Sair\n"
filename: .asciiz "input.txt"

.text
main:
	jal openfile
	move $s0, $v0 # s0 = file descriptor
	jal menu
	li $s1, 1
	li $s2, 2
	li $s3, 3
	beq $v0, $s1, words_frequency
	beq $v0, $s2, chars_frequency
	beq $v0, $s3, hault
	j main
	
words_frequency:
	j main

chars_frequency:
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
		j main

openfile:
	li $v0, 13, # syscall code to open file
	la $a0, filename
	li $a1, 0 # flag mode = 0 (read)
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