.section .bss
input_buffer: .space 256          # Allocate 256 bytes for input buffer
output_buffer: .space 12          # Allocate 12 bytes for output buffer

.section .data

add: .string "0000000 "  # machine code for addition instruction
sub: .string "0100000 "  # machine code for substraction instruction
mul: .string "0000001 "  # machine code for multiplication instruction
xor: .string "0000100 "  # machine code for bitwise xor instruction
and: .string "0000111 "  # machine code for bitwise and instruction
or: .string "0000110 "  # machine code for bitwise or instruction
funct3:.string "000 "  # machine code for funct3
x0: .string " 00000 "  # machine code for register x0
x1:.string "00001 "   # machine code for register x1
x2: .string "00010 "   # machine code for register x2
r_opcode:.string "0110011\n"   # r type opcode
i_opcode: .string "0010011\n"  # i type opcode


.section .text
.global _start


_start:
    # Read input from standard input

    mov $0, %eax                    # syscall number for sys_read
    mov $0, %edi                    # file descriptor 0 (stdin)
    lea input_buffer(%rip), %rsi    # pointer to the input buffer
    mov $256, %edx                  # maximum number of bytes to read
    syscall          
    
    xor %cx, %cx               # perform the syscall

    jmp evaluate_postfix       # jump to evaluate_postfix label


evaluate_postfix:
    # evaluates given postfix input

    cmp %rsi, %rbx
    je exit_program   # if the character is end of the input, exit the program
    movzbl (%rsi), %eax   # iterate input one by one
    cmp $0x0A, %al
    je exit_program  # if the character is new line, exit the program
    cmp $0x20, %al 
    je increment_pointer  # if the character is space, increment the pointer
    cmp $0x30, %al
    jb print_addi # check if below zero
    cmp $0x39, %al
    ja print_addi  # check if above nine
    sub $0x30, %eax   # substract '0' to get the numerical value
    mov %eax, %ebx   # store ax in bx since ax is going to change
    mov %ecx, %eax   
    mov $0x3A, %ecx
    sub $0x30, %ecx
    mul %ecx    # multiply ax by 10
    add %ebx, %eax  # add stored value to the ax that is multiplied by 10
    mov %eax, %ecx
    
    inc %rsi    # increment the pointer
    jmp evaluate_postfix   # recursive

increment_pointer:
    inc %rsi   # increment the pointer
    push %cx   # push the last seen number to the stack   
    mov $0, %cx
    jmp evaluate_postfix   # keep evaluating

check_operator:
    mov %r9d, %eax
    cmp $0x2B, %al
    je perform_addition    # if the character is '+', add x1 to x2 and push x1 to the stack
    cmp $0x2D, %al
    je perform_substraction  # if the character is '-', substract x1 from x2 and push x1 to the stack
    cmp $0x2A, %al
    je perform_multiplication # check if the character is '*', multiply x1 by x2 and push x1 to the stack
    cmp $0x5E, %al
    je perform_xor   # if the character is '^', perform bitwise xor between x1 and x2, and push x1 to the stack
    cmp $0x26, %al
    je perform_and   # if the character is '&', perform bitwise and between x1 and x2, and push x1 to the stack
    cmp $0x7C, %al
    je perform_or   # if the character is '|', perform bitwise or between x1 and x2, and push x1 to the stack
    jmp exit_program


perform_addition:
    add %r10w, %r15w    # perform the addition operation

    mov $add, %esi  # print the machine code for addition
    mov $1, %eax             
    mov $1, %edi  
    mov $8, %edx            
    syscall

    mov $1, %eax    # print the machine code for register x2
    mov $1, %edi  
    mov $x2, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax   # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx      
    syscall

    mov $1, %eax    # print the machine code for funct3            
    mov $1, %edi  
    mov $funct3, %esi
    mov $4, %edx      
    syscall

    mov $1, %eax    # print the machine code for register x1               
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx      
    syscall

    mov $1, %eax    # print the machine code for r type opcode            
    mov $1, %edi  
    mov $r_opcode, %esi
    mov $8, %edx       
    syscall


    mov %r12, %rsi  # restore the value of rsi from r12
    inc %rsi    # increment the pointer
    mov %r15w, %cx  # store the value of r15w in cx
    jmp evaluate_postfix    

perform_substraction:
    sub %r10w, %r15w    # perform the substraction operation

    mov $sub, %esi  # print the machine code for substraction
    mov $1, %eax             
    mov $1, %edi  
    mov $8, %edx           
    syscall

    mov $1, %eax    # print the machine code for register x2              
    mov $1, %edi  
    mov $x2, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for funct3             
    mov $1, %edi  
    mov $funct3, %esi
    mov $4, %edx      
    syscall

    mov $1, %eax    # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx      
    syscall

    mov $1, %eax    # print the machine code for r type opcode              
    mov $1, %edi  
    mov $r_opcode, %esi
    mov $8, %edx      
    syscall

    mov %r12, %rsi  # restore the value of rsi from r12
    inc %rsi    # increment the pointer
    mov %r15w, %cx  # store the value of r15w in cx
    jmp evaluate_postfix


perform_multiplication:
    mov %r15w, %ax  # perform the multiplication operation
    mul %r10w
    mov %ax, %r15w

    mov $mul, %esi  # print the machine code for multiplication
    mov $1, %eax             
    mov $1, %edi  
    mov $8, %edx            
    syscall

    mov $1, %eax    # print the machine code for register x2             
    mov $1, %edi  
    mov $x2, %esi
    mov $6, %edx      
    syscall

    mov $1, %eax    # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for register funct3              
    mov $1, %edi  
    mov $funct3, %esi
    mov $4, %edx       
    syscall

    mov $1, %eax    # print the machine code for register x1             
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for r type opcode              
    mov $1, %edi  
    mov $r_opcode, %esi
    mov $8, %edx       
    syscall

    mov %r12, %rsi  # restore the value of rsi from r12
    inc %rsi    # increment the pointer
    mov %r15w, %cx  # store the value of r15w in cx
    jmp evaluate_postfix
    

perform_xor:
    xor %r10w, %r15w    # perform the xor operation
 
    mov $xor, %esi  # print the machine code for xor
    mov $1, %eax            
    mov $1, %edi  
    mov $8, %edx           
    syscall

    mov $1, %eax    # print the machine code for register x2                        
    mov $1, %edi  
    mov $x2, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for funct3            
    mov $1, %edi  
    mov $funct3, %esi
    mov $4, %edx       
    syscall

    mov $1, %eax    # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for r type opcode              
    mov $1, %edi  
    mov $r_opcode, %esi
    mov $8, %edx      
    syscall

    mov %r12, %rsi  # restore the value of rsi from r12
    inc %rsi    # increment the pointer
    mov %r15w, %cx  # store the value of r15w in cx
    jmp evaluate_postfix


perform_and:
    and %r10w, %r15w    # perform the and operation

    mov $and, %esi  # print the machine code for and
    mov $1, %eax             
    mov $1, %edi  
    mov $8, %edx           
    syscall

    mov $1, %eax    # print the machine code for register x2              
    mov $1, %edi  
    mov $x2, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for funct3             
    mov $1, %edi  
    mov $funct3, %esi
    mov $4, %edx      
    syscall

    mov $1, %eax    # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for r type opcode              
    mov $1, %edi  
    mov $r_opcode, %esi
    mov $8, %edx      
    syscall

    mov %r12, %rsi  # restore the value of rsi from r12
    inc %rsi    # increment the pointer
    mov %r15w, %cx  # store the value of r15w in cx
    jmp evaluate_postfix


perform_or:
    or %r10w, %r15w   # perform the or operation

    mov $or, %esi   # print the machine code for or
    mov $1, %eax            
    mov $1, %edi  
    mov $8, %edx            
    syscall

    mov $1, %eax    # print the machine code for register x2             
    mov $1, %edi  
    mov $x2, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for register x1             
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx      
    syscall

    mov $1, %eax    # print the machine code for funct3              
    mov $1, %edi  
    mov $funct3, %esi
    mov $4, %edx       
    syscall

    mov $1, %eax    # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx      
    syscall

    mov $1, %eax    # print the machine code for r type opcode             
    mov $1, %edi  
    mov $r_opcode, %esi
    mov $8, %edx       
    syscall

    mov %r12, %rsi  # restore the value of rsi from r12
    inc %rsi    # increment the pointer
    mov %r15w, %cx  # store the value of r15w in cx
    jmp evaluate_postfix



print_addi:
    mov %rsi, %r12  # store the value of rsi in r12
    mov %eax, %r9d  # store the value of eax in r9d

    pop %r10w   # pop the last seen number from the stack and assign it to r10w
    pop %r15w   # pop the last seen number from the stack and assign it to r15w

    mov $0x0C, %r13w    # use r13 as a counter for the number of bits    

    mov %r10w, %ax  
    lea output_buffer(%rip), %r14   
    add $0x0B, %r14w    # start from the end of the output buffer

    jmp convert_x2  # convert x2 to binary
    

convert_x2:
    xor %edx, %edx  # reset edx

    mov $0x02, %ecx # divide by 2
    div %ecx

    add $0x30, %dl  # convert to ascii
    movb %dl, (%r14)    # store the ascii value in the output buffer

    dec %r14w   # decrement the pointer
    dec %r13w   # decrement the counter

    jz print_x2     # if the counter is zero, print the output buffer
    jmp convert_x2  # recursive

print_x2:
    lea output_buffer(%rip), %rsi   # print the 12 bit binary value of x2    
    mov $1, %eax             
    mov $1, %edi  
    mov $12, %edx            
    syscall

    mov $1, %eax    # print the machine code for register x0              
    mov $1, %edi  
    mov $x0, %esi
    mov $7, %edx       
    syscall

    mov $1, %eax    # print the machine code for funct3             
    mov $1, %edi  
    mov $funct3, %esi
    mov $4, %edx       
    syscall

    mov $1, %eax    # print the machine code for register x2              
    mov $1, %edi  
    mov $x2, %esi
    mov $6, %edx       
    syscall

    mov $1, %eax    # print the machine code for i type opcode             
    mov $1, %edi  
    mov $i_opcode, %esi
    mov $8, %edx       
    syscall

    mov %r15w, %ax  
    mov $0x0C, %r13w

    lea output_buffer(%rip), %r14
    add $0x0B , %r14w

    jmp convert_x1 # convert x1 to binary


convert_x1:
    xor %edx, %edx  # reset edx

    mov $0x02, %ecx # divide by 2
    div %ecx

    add $0x30, %dl  # convert to ascii
    movb %dl, (%r14)    # store the ascii value in the output buffer

    dec %r14w   # decrement the pointer
    dec %r13w   # decrement the counter

    jz print_x1    # if the counter is zero, print the output buffer
    jmp convert_x1  # recursive

print_x1:
    lea output_buffer(%rip), %rsi   # print the 12 bit binary value of x1
    mov $1, %eax                  
    mov $1, %edi  
    mov $12, %edx            
    syscall

    mov $1, %eax    # print the machine code for register x0            
    mov $1, %edi  
    mov $x0, %esi
    mov $7, %edx       
    syscall

    mov $1, %eax    # print the machine code for funct3              
    mov $1, %edi  
    mov $funct3, %esi
    mov $4, %edx       
    syscall

    mov $1, %eax    # print the machine code for register x1              
    mov $1, %edi  
    mov $x1, %esi
    mov $6, %edx      
    syscall

    mov $1, %eax    # print the machine code for i type opcode              
    mov $1, %edi  
    mov $i_opcode, %esi
    mov $8, %edx       
    syscall

    mov %r12, %rsi  # restore the value of rsi from r12
    jmp check_operator  # continue to check the operator

exit_program:
    # exit the program
    mov $60, %eax              
    xor %edi, %edi              
    syscall
