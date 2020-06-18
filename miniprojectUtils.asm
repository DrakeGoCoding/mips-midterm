#Filename: 	miniprojectUtils.asm
#Purpose: 	define utilities which will be used in miniprojects
#Author:	 	Nguyen Huy Hoang	20184265
#       	 	Phi Hoang Long   	  	20184288
#		 	Le Ba Vinh       		20184331
#
#Subprogram index:
#        		abort
#			appendStringRegister
#        		checkValidNatural
#        		copyChar
#        		forLoop
#        		getAddressAtIndex
#        		getCharDistance
#			getDigitString
#        		getIntDialog
#        		getLengthRegister
#        		getLengthLabel
#        		getOrdinal
#        		getStringDialog
#			getStringIndex
#        		increaseBy1
#        		popRegister
#        		printIntLabel
#        		printStringLabel
#			printStringRegister
#        		printLiteral
#			printStringInt
#			printStringString
#        		pushRegister

#Subprogram: 	abort
#purpose: 	  	print abort string to console
#input:       		none
#output: 	  		none
#side effects: 		exit program

.macro abort()

.data
	alertMessage: .asciiz "Invalid input\n"
	exitMessage: .asciiz "Exitting..."
.text
	printStringString(alertMessage, exitMessage)
	li $v0, 10
	syscall
.end_macro

#Subprogram: 	appendStringRegister
#purpose:		append a string from a register to a given label
#input:			%destination - destination
#				%source - input register contains string to be appended
#output:			%destination = %destination.append(%source)
#side effects:		none

.macro appendStringRegister(%destination, %source)
.text
	pushRegister($v0)
	pushRegister($a0)
	pushRegister($a1)

	la $a1, (%source)			#source
	la $a0, %destination		#destination
	getLengthRegister($a0)
	add $a0, $a0, $v0
	
append:
	lb $v0, ($a1)			#get the current char
	beqz $v0, done			#if char is EOS, goto done
	sb $v0, ($a0)				#store the current char
	addi $a0, $a0, 1			#advance destination pointer
	addi $a1, $a1, 1			#advance source pointer
	j append

done:
	sb $zero, ($a0)			#add EOS to %label
	popRegister($a1)
	popRegister($a0)
	popRegister($v0)
.end_macro

#Subprogram: 	appendLiteral
#purpose:		append a string to a label
#input:			%label, %string
#output:			%label = %label.append(%string)
#side effects:		none

.macro appendLiteral(%label, %string)
.data
	__string__: .asciiz %string
.text
	pushRegister($v0)
	
	la $v0, __string__
	appendStringRegister(%label, $v0)

	popRegister($v0)
.end_macro


#Subprogram:  	checkValidNotNegative
#purpose: 	  	only accept non-negative or empty input 
#input:       		%value - register contains value 
#             			%status - register contains status
#output: 	  		none
#side effects: 		none

.macro checkValidNotNegative(%value, %status)
	pushRegister($t0)
	pushRegister($t1)
	pushRegister($t2)

	move $t0,%value  		# t0 = value
	move $t1,%status 		# t1 = status

	seq $t2, $t1, $zero 		# status = 0?
	beqz $t2, not_okay

	sge $t2, $t0, 0     		# value >= 0 ?
	beqz $t2, not_okay

	j okay
not_okay:
	abort()
	j end_check
okay:

end_check:
	popRegister($t2)
	popRegister($t1)
	popRegister($t0)
.end_macro

#Subprogram:  	copyChar
#purpose: 	  	duplicate a character from a register to another
#input:       		%source - register to be duplicated
#                		%destination - register to duplicate to
#output: 	  		%destination contains a duplicated character from %source
#side effects: 		none

.macro copyChar(%destination, %source)
	pushRegister($t9)
	lb $t9, (%source)
	sb $t9, (%destination)
	popRegister($t9)
.end_macro

#Subprogram:  	forLoop
#purpose: 	  	C-style for-loop
#input:       		%init - function (.macro) contains initial value source code
#             			%cond - function (.macro) contains condition source code
#             			%increment - function (.macro) contains increment index source code
#            			%body - function (.macro) contains source code for looping 
#output: 	  		indeterminate
#side effects: 		none

.macro forLoop(%init, %cond, %increment, %body)
    	%init
    	
loop:
	pushRegister($v0)

condition: 	
	#result -----> $v0 (0/1)
	#ìf $v0 = 0 , goto end_loop
    	%cond
	beqz $v0, end_loop
	popRegister($v0)

action:
	%body

increment:
	%increment
	j loop

end_loop:
	popRegister($v0)

.end_macro

#Subprogram:  	getAddressAtIndex
#purpose: 	  	find address of an element in array
#input:       		%str - label contains string input
#             			%index - label contains index
#output: 	  		$a0 contains address result
#side effects: 		none

.macro getAddressAtIndex(%str, %index) 
	# $a0 = & %str[%register]
	pushRegister($t0)
	lw $t0, %index
	la $a0, %str
	add $a0, $a0, $t0
	popRegister($t0)

.end_macro

#Subprogram:  	getCharDistance
#purpose: 	  	find the difference in ASCII table of 2 registers, each of which contain a character
#input:       		%register_1 - first register
#             			%register_2 - second register 
#output: 	  		$v0 = abs(%register_1 - % register)
#side effects: 		none

.macro getCharDistance(%register_1, %register_2)
	pushRegister($t0)
	pushRegister($t1)
	lb $t0, (%register_1)
	lb $t1, (%register_2)
	sub $t0, $t0, $t1
	abs $v0, $t0  
	popRegister($t1)
	popRegister($t0)
.end_macro

#Subprogram:		getDigitString
#purpose:		convert a digit to string
#input:			%reg contains digit
#output:			$v1 now contains digit string
#side effects: 		none

.macro getDigitString(%reg)

.data
	zero: .asciiz "0"
	one: .asciiz "1"
	two: .asciiz "2"
	three: .asciiz "3"
	four: .asciiz "4"
	five: .asciiz "5"
	six: .asciiz "6"
	seven: .asciiz "7"
	eight: .asciiz "8"
	nine: .asciiz "9"
.text	
	pushRegister($t9)
	move $t9, %reg
	beq $t9, 0, loadZero
	beq $t9, 1, loadOne
	beq $t9, 2, loadTwo
	beq $t9, 3, loadThree
	beq $t9, 4, loadFour
	beq $t9, 5, loadFive
	beq $t9, 6, loadSix
	beq $t9, 7, loadSeven
	beq $t9, 8, loadEight
	beq $t9, 9, loadNine
loadZero:
	la $v1, zero
	j continue
loadOne:
	la $v1, one
	j continue
loadTwo:
	la $v1, two
	j continue
loadThree:
	la $v1, three
	j continue
loadFour:
	la $v1, four
	j continue
loadFive:
	la $v1, five
	j continue
loadSix: 
	la $v1, six
	j continue
loadSeven: 
	la $v1, seven
	j continue
loadEight:
	la $v1, eight
	j continue
loadNine:
	la $v1, nine
	j continue

continue:
	popRegister($t9)
.end_macro

#Subprogram:  	getIntDialog
#purpose: 	 	get integer input using a dialog
#input:      	 	%label - input label
#             			%message - message label
#output: 	  		%label contains input value
#side effects: 		none

.macro getIntDialog(%label, %message)
    	# int ---> %label
    	# status --> v1
    	# if bad status ---> abort?
    	pushRegister($a0)
    	pushRegister($a1)
    	pushRegister($v0)

    	#Print message dialog 
    	li $v0,51
    	la $a0, %message
    	syscall

    	#Check valid input
    	checkValidNotNegative($a0, $a1)

   	sw $a0, %label
    	move $v1,$a1
	
    	popRegister($v0)
    	popRegister($a1)
    	popRegister($a0)

.end_macro

#Subprogram:  	getLengthRegister
#purpose: 	  	find the length of a string in a register
#input:       		%register - register contains string
#output: 	  		$v0 = length
#side effects: 		none

.macro getLengthRegister(%register)
   	#Get length of string in $1 to $v0
   	pushRegister($a0)
  	pushRegister($t1)
  	pushRegister($t2)

__get_length__:
	move $a0, %register
	#set $v0 = length = 0
	xor $v0, $zero $zero		

__check_char__:
	add $t1, $a0, $v0			    	# t1 = &x[i]  =  a0 + t0							
	lb $t2, 0($t1)				    	# t2 = x[i]
	beq $t2, $zero, __end_of_str__	# if (x[i] == null) break
	addi $v0, $v0, 1			    	# length++
	j __check_char__

__end_of_str__:
__end_of_get_length__:
	addi $v0, $v0, 0			   	 # correct length to saved register
	popRegister($t2)
	popRegister($t1)
	popRegister($a0)

.end_macro

#Subprogram:  	getLengthLabel
#purpose: 	  	find the length of a label that contains a string
#input:       		%label - input label
#output: 	  		$v0 = length
#side effects:		 none

.macro getLengthLabel(%label)
	pushRegister($a0)
	la	$a0, %label
	getLengthRegister($a0)
	popRegister($a0)
.end_macro

#Subprogram:  	getOrdinal
#purpose: 	  	find ASCII value of a character
#input:       		%address - input register that contains a character
#output: 	  		$v0 - ASCII value of the character
#side effects: 		none

.macro getOrdinal(%address)
	lw $v0, %address
.end_macro

#Subprogram:  	getStringDialog
#purpose: 	  	get string input using a dialog
#input:       		%label - input label
#output: 	  		%label contains input value
#side effects: 		none

.macro getStringDialog(%label)
	pushRegister($v0)
	pushRegister($a0)
	pushRegister($a1)
	pushRegister($a2)

.data 
	message: .asciiz "Please input a string: "

.text
	la $a0, message
	la $a1, %label
	li $a2, 100
	li $v0, 54
	syscall

	getLengthLabel(%label)

	la $a0, %label
	add $a0, $a0, $v0
	addi $a0, $a0, -1

	sb $zero, 0($a0)

	popRegister($a2)
	popRegister($a1)
	popRegister($a0)
	popRegister($v0)

.end_macro

#Subprogram:		getStringIndex

.macro get_str_index(%arr, %register_index)

	# $v0 = $1`'[$2]

	pushRegister($t0)
	pushRegister($t1)

	#$t0 = $2, $t1 = $1
	pushRegister(%register_index)
	popRegister($t0)

	la $t1, %arr

	add $t0, $t1, $t0
	lb $v0, 0($t0)

	popRegister($t1)
	popRegister($t0)

.end_macro

#Subprogram:  	increaseBy1
#purpose: 	  	print abort string to console
#input:       		%label - input register
#output: 	  		%label++
#side effects: 		none

.macro increaseBy1(%label)
	pushRegister($t9)
	lw $t9, %label
	addi $t9, $t9, 1
	sw $t9, %label
	popRegister($t9)
.end_macro

#Subprogram:  	popRegister
#purpose: 	 	 pop from stack
#input:       		%register
#output: 	  		$sp is popped into %register
#side effects: 		none

.macro popRegister(%register)
	lw %register, 0($sp)
	addi $sp, $sp, 4
.end_macro

#Subprogram:  	printIntLabel
#purpose: 	  	print integer from a label
#input:       		%label
#output: 	  		print to console
#side effects: 		none

.macro printIntLabel(%label)

    	pushRegister($v0)
    	pushRegister($a0)

   	li $v0,1
    	lw $a0, %label
    	syscall

    	popRegister($a0)
    	popRegister($v0)

.end_macro

#Subprogram:		printIntRegister
#purpose:		print an integer from a register
#input:			%reg 
#output:			print to console
#side effects:		none

.macro printIntRegister(%reg)
	pushRegister($v0)
	pushRegister($a0)
	li $v0, 1
	move $a0, %reg
	syscall
	popRegister($a0)
	popRegister($v0)
.end_macro

#Subprogram:  	printStringLabel
#purpose: 	  	print string from a label
#input:       		%label
#output: 	  		print to console
#side effects: 		none

.macro printStringLabel(%label)

    	pushRegister($v0)
   	pushRegister($a0)

	li	$v0, 4
	la	$a0, %label
	syscall

	popRegister($a0)
	popRegister($v0)

.end_macro

#Subprogram:  	printStringRegister
#purpose: 	  	print string from a register
#input:       		%reg
#output: 	  		print to console
#side effects: 		none

.macro printStringRegister(%reg)

    	pushRegister($v0)
   	pushRegister($a0)

	li	$v0, 4
	move $a0, %reg
	syscall

	popRegister($a0)
	popRegister($v0)

.end_macro

#Subprogram:  	printLiteral
#purpose: 	  	print out an input string to console
#input:       		%string - string to print out
#output: 	  		print to console
#side effects: 		none

.macro printLiteral(%string)

.data
	__string__: .asciiz %string
.text
	pushRegister($v0)
	pushRegister($a0)

	li $v0, 4
	la $a0, __string__
	syscall

	popRegister($a0)
	popRegister($v0)

.end_macro

#Subprogram:		printStringInt
#purpose:		print a string followed by an integer inside a pop-up dialog
#input:			%label_string - input string
#				%label_int - input integer
#output:			"%label_string %label_int"
#side effects:		none

.macro printStringInt(%label_string, %label_int)
	pushRegister($a0)
	pushRegister($a1)

	li $v0, 56
	la $a0, %label_string
	lw $a1, %label_int
	syscall

	popRegister($a1)
	popRegister($a0)
.end_macro

#Subprogram:		printStringString
#purpose:		print a string followed by another string inside a pop-up dialog
#input:			%label_stringA - input string A
#				%label_stringB - input string B
#output:			"%label_stringA %label_stringB"
#side effects:		none

.macro printStringString(%label_stringA, %label_stringB)
	pushRegister($a0)
	pushRegister($a1)

	li $v0, 59
	la $a0, %label_stringA
	la $a1, %label_stringB
	syscall

	popRegister($a1)
	popRegister($a0)
.end_macro

#Subprogram:  	 pushRegister
#purpose: 	 	 push a register into stack
#input:       	 	%register - register to push
#output: 	  		$sp with new peek %register
#side effects: 		none

.macro pushRegister(%register)
	addi $sp, $sp, -4
	sw %register, 0($sp)
.end_macro 
