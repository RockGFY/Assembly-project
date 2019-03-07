# who:	Group: Fengyi Guo and Dongri Zhu
# what:	Project 4 Fengyi Guo.asm 
# why:	Project 4: a program that accepts integer values from user input. You must first prompt the user
#		for the quantity of integers to be read. These integers must be stored in the stack. 		 	
#		before writing a subroutine that performs a binary search on the data entered by the user, 
#		the contents of the stack aresorted. 
# when:	created at 5/19/2018, due data: 5/25/2018
# how:	read a the quantity of integers from user, read those integers from user, then store 
#		them to stack, sort these integers, then read an integer from user for searching 
#		it, print the stack at the end.

.data
	
	prompt:			.asciiz	"Please enter the quantity of integers to be stored: "
	inputMsg:		.asciiz	"\nEnter integer: "
	stackMsg:		.asciiz "\nthe stack inclouds: \n"
	msg_inputSearch:	.asciiz "\nPlease enter the number to search: "
	msg_found:		.asciiz	"\nWe have found it."
	msg_notFound:		.asciiz "\nThe input is not found in the stack."
	newLine:		.asciiz	"\n"
	newSpace:		.asciiz	" "
	endMsg:			.asciiz "\n\n\nBye bye..."
	
.text
.globl main

main:
	
	move	$s1, $ra			# store return address
	
	li 	$v0, 4				# print string
	la 	$a0, prompt	
	syscall
	
	li 	$v0, 5				# read integer from the user
	syscall
	
	move 	$t9, $v0			# store n to t9
	
	sll	$a1, $t9, 2			# space = size * 4
	
	li 	$t0, 0				# counter 
	li 	$s0, 0       			# number of integers initialize
		
readIntegerLoop:
	bge 	$t0, $t9, sortStack		# if t0 >= n, jump to sortStack
	
	li 	$v0, 4				# print string
	la 	$a0, inputMsg	
	syscall
	
	li 	$v0, 5				# read integer from the user
	syscall
		
	jal 	addIntegerToStack		# call subroutine to push integer into stack
	
	addi 	$t0, $t0, 1 			# increase counter
	
	j 	readIntegerLoop
	
sortStack:
	beq 	$s0, 0, end  			# check if number of n*4 is > 0,
	move 	$t0,$sp       			# outerloop counter
    	add 	$t4,$sp,$s0    			# outerloop termination
  	addi 	$t4,$t4,-4
	
sortStackLoop:
	move 	$t1,$sp       			# innerloop counter
   	sub 	$t6,$t0,$sp     		# inner loop end condition
  	sub 	$t6,$t4,$t6

sortStackLoopCont: 
	lw 	$t2, 0($t1)        		# get first int
   	lw 	$t3, 4($t1)          		# get second int
    	slt	$t5, $t2, $t3        		# if n[0] < n[+1] set t5 = 1
    	bne 	$t5, $zero, swapFalse 		# if $t5 == 0 !swap ... else swap
    	move 	$t5, $t2           		# move $t2 into $t5
    	move 	$t2, $t3          		# move $t3 into $t2
    	move 	$t3, $t5          		# move $t5 into $t3
    	sw 	$t2, 0($t1)         		# restore back to stack swapped
    	sw 	$t3, 4($t1)   

swapFalse:	
	addi 	$t1,$t1,4         		# increment to next int
   	bne 	$t1,$t6,sortStackLoopCont 	# if not end then back to loop
	
	addi 	$t0,$t0,4          		# increment outer loop counter
    	bne 	$t0,$t4,sortStackLoop 		# if !=$t0 back to loop else:
	
	li 	$v0, 4
	la 	$a0, newLine
	syscall
	
	li 	$v0, 4
	la 	$a0, stackMsg
	syscall
	
	jal printArray
	
	j binarySearch
	
addIntegerToStack:				# subroutine for push input to stack
	addi 	$sp, $sp, -4			# move the pointer to create space
	sw 	$v0, 0($sp)			# store the input to stack
	addi 	$s0, $s0, 4    			# store stack counter in s0
	jr 	$ra
	
printArray:
	move 	$t5, $sp           		# print counter
    	add 	$t2,$s0,$t5       		# end condition
    	
printArrayLoop:
    	li 	$v0, 1             		# opcode print int
    	lw 	$a0,0($t5)          		# arg for print int
    	syscall     
	
    	li 	$v0,4              	 	# print string
    	la 	$a0,newSpace           		# space
    	syscall
	
    	addi 	$t5,$t5,4           		# next int
    	bne 	$t5,$t2,printArrayLoop  	# if int left then print next
	
    	jr 	$ra                  		# return to caller
	
end:
	
	li 	$v0, 4
	la 	$a0, endMsg	
	syscall
	
	li	$v0, 10				# Exit Program
	syscall
	
#-----------------------------------------------------------------------------------	
#-----------------------------------------------------------------------------------
	
binarySearch:
	# read the input
    	li      $v0, 4                  
    	la   	$a0, msg_inputSearch    	# load msg of for the input
    	syscall                             
    	
    	li      $v0, 5                  	# read input
    	syscall                 
    
    	move    $t0, $v0               		# assign input to $t0
    	
	move 	$t1, $sp       	    		# assign the end address
	
	move	$s7, $t9			# $s7 always contains max index
	li	$s6, 1				# $s6 always contains min index
	
	li	$v1, 2				
	div	$t9, $v1			# divide the size by 2
						# $t9 contains initial max index
	mflo    $t8                     	# $t8 always contains mid index
	
	# NOT FOUND CONDITION and FOUND CONDITION withouth binary search
	
	add	$t1, $t1, $a1		
	addi	$t1, $t1, -4
	lw	$t2, 0($t1)			# load the largest value to $t2

	bgt	$t0, $t2, notFound		# if the input is greater than largest number in stack, 
						# branch notFound right away					
	beq	$t0, $t2, found			# if the input is equal to lagest number in stack, 
						# branch notFound right away
						
	
	move	$t1, $sp			# restore the address
					
	lw	$t2, 0($t1)			# load the smallest value to $t2

	beq	$t0, $t2, found			# if the input is equal to smallest number in stack, 
						# branch notFound right away 
	blt	$t0, $t2, notFound		# if the input is less than smallest number in stack, 
						# branch notFound right away
	
search:
	ble	$s7, $s6, notFound		# if max is less than equal to min, branch not found
	
	move	$t7, $t8			# take $t7 as counter
	
	jal	getTheMidInt			# the mid integer stored in $s1
						# now the $t1 is pointing the mid
						
	beq	$t0, $s1, found			# if mid == input, we found it			
	
	slt	$t2 $t0, $s1			# if input is less than the mid int, $t2=1
	beq	$t2, $zero, searchHigh		# $t2=0 means input is greater than mid int, so search high
	j	searchLow			# else search low    
	

getTheMidInt: 

	lw	$s1, 0($t1)			# the midpoint number stores in $s1

	beq	$t7, $s6, endGet		# if mid == min branch endGet
	
	addi	$t1, $t1, 4
	
	beq	$t7, $s6, endGet		# if mid == min branch endGet
	addi	$t7, $t7, -1
	
	j	getTheMidInt

endGet:
	jr	$ra


searchHigh:
	move	$s6, $t8			# min becomes mid
	add	$t8, $s6, $s7			# add mid and max
	li	$v1, 2				
	div	$t8, $v1			# divide the sum of index by 2
	mflo    $t8                     	# the higher mid index stores in $t8
	
	j	search
	
searchLow:
	move	$s7, $t8			# max becomes mid
	add	$t8, $s6, $s7			# add mid and max
	li	$v1, 2				
	div	$t8, $v1			# divide the sum of index by 2
	mflo    $t8                     	# the lower mid index stores in $t8
	
	li	$v1, 4				
	mult	$s6, $v1			
	mflo    $t6                     	
	
	move 	$t1, $sp       	    		# assign the end address
	add	$t1, $t1, $t6			# shift to min address
	
	j	search	


found:		# when we found the input
	li 	$v0, 4
	la 	$a0, msg_found	
	syscall
	
	j	end
	
notFound:	# when we not found the input
	li 	$v0, 4
	la 	$a0, msg_notFound	
	syscall
	
	j	end

