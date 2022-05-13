.global _start // weafweef

.section .text
_start:
    movq src, %rax
    movq dst, %rbx
    cmp %rax, %rbx #handle src=dst
    je END_HW1
    leaq head(%rip), %rdi #%rdi holds the address of the head of the list
    leaq (%rdi), %r12 #%r12 is a pointer to previous node next pointer address
    movq (%rdi), %rdi #now %rdi will hold the address of A
    testq %rdi, %rdi #handle empty list
    je END_HW1
    xor %rbp, %rbp #adjacent src and dst nodes indicator
    xor %r8, %r8 #src occurences counter
    xor %r9, %r9 #dst occurences counter

.LOOP_HW1: #check every node in the list, if value is equal to src
           #or dst - increase its counter by 1, if counter value is greater
           #than 1, jump to end
    movq (%rdi), %rdx #get current node data 
    cmpq %rax, %rdx
    je .EQUAL_SRC_HW1
    cmpq %rbx, %rdx
    je .EQUAL_DST_HW1
    leaq 8(%rdi), %r12 #now %r12 will hold the address of previous node next field
    movq 8(%rdi), %rdi #now %rdi will hold the address of B
    testq %rdi, %rdi
    jne .LOOP_HW1
    jmp .SWAP_CHECK_HW1
    
.EQUAL_DST_HW1:
    cmpq $0x0, %r9    
    jne END_HW1
    incq %r9
    movq %r12, %rsi #store dst previous node next pointer address
    leaq 8(%rdi), %r14 #store dst next node pointer address
    movq 8(%rdi), %r15
    cmp $0, %r15 #handle last node in the list
    je .SWAP_CHECK_HW1
    movq (%r15), %r11
    movq (src), %rsp
    cmp  %r11, %rsp #handle following dst and src nodes inside list
    jne .CONT_LOOP_HW1
    movq $-1, %rbp
    leaq 8(%rdi), %r12
    movq 8(%rdi), %rdi
    testq %rdi, %rdi
    jne .LOOP_HW1
    jmp .SWAP_CHECK_HW1

.EQUAL_SRC_HW1:
    cmpq $0x0, %r8
    jne END_HW1
    incq %r8
    movq %r12, %r10 #store src previous node next pointer address
    leaq 8(%rdi), %r13 #store src next node pointer address
    movq 8(%rdi), %r15
    cmp $0, %r15 #handle last node in the list
    je .SWAP_CHECK_HW1
    movq (%r15), %r11
    movq (dst), %rsp
    cmp  %r11, %rsp #handle following src and dst nodes inside list
    jne .CONT_LOOP_HW1
    movq $1, %rbp
    leaq 8(%rdi), %r12
    
.CONT_LOOP_HW1:
    movq 8(%rdi), %rdi
    testq %rdi, %rdi
    jne .LOOP_HW1

.SWAP_CHECK_HW1:
    cmpq $1, %r8
    jne END_HW1
    cmpq $1, %r9
    jne END_HW1

.SWAP_HW1:
    movq (%r10), %r8
    movq (%rsi), %r9
    movq (%r9), %r9
    cmpq $0, %rbp
    jne .adjacent_HW1
    movq (%r10), %rcx #%rcx is a temp register
    movq (%r13), %rsp #%rsp is a temp register
    movq (%rsi), %rbp
    movq %rbp, (%r10)
    movq %rcx, (%rsi)
    movq (%r14), %rbp
    movq %rbp, (%r13)
    movq %rsp, (%r14)
    jmp END_HW1
    
.adjacent_HW1:
    cmpq $-1, %rbp
    jne .SRC_BFR_DST_HW1
    movq %r10, %rcx #handle dst before src
    movq %r13, %rdx
    movq %rsi, %r10
    movq %rcx, %rsi
    movq %r14, %r13
    movq %rdx, %r14
    
.SRC_BFR_DST_HW1:
    movq (%r10), %rcx #%rcx is a temp register
    movq (%rsi), %rbp
    movq %rbp, (%r10)
    movq (%r14), %rbp
    movq %rbp, (%r13)
    movq %rcx, (%r14)
    
END_HW1: