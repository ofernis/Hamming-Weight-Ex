.global hamming_weight, negate_first_k, bring_balance_to_the_word, read_input

.section .bss
.lcomm path, 1024

.section .text

read_input:
    pushq %rbp      // save old value of %rbp because we are going to change it in the next command.
    movq %rsp, %rbp // update %rbp when entering the function in order to use it as a base pointer - now %rbp point to the start of the function in the stack
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    
    // via the conventions, %rdi contains the address of an array thats need to be fillied.
    movq %rdi, %rbx //#-----rbx contain codeword address.

   // moveq path, %rdi //#--------------need to check if thats how u transfer the buffer to be written to. אסור להשתמש בשיטת מיון אבסולוטית-------------------------
    lea path(%rip), %rdi // 
    call get_path
     //# now i should assume that in this addres - $path - there is the path to the file.
    lea path(%rip), %rdi
    movq $2, %rax //# 2 - means that i want to open
    movq $0, %rsi //# flag that this file is open just for read!!
    movq $256, %rdx //# granting relevant permissions
    syscall //# sys_open - y do i need to open befor i read? for the file descriptor number right? i knew that!
     // # now the file is open and rax containg the fd of the file - because this is the returning value of sys_open.

    movq %rax, %rdi //# --------------------do i need to backup %rdi before syscall? 
    //# now the fd is in %rdi, because we r gonna call sys_read.

    movq %rax, %r14
    // ---------------------------------------------- %r14 contain a backup for fd of the file.-------------------------------------------------
    //--------------------------------------------------------------- the file is open ---------------------------------------------------
    lea path(%rip), %rsi
    // # an adress to the array that will contain the string that has been read.
loop1:
    movq $0, %rax // now the service we want is - to read!
    //# now the file is open, its fd is in %rdi, now we need to read from the file.
    //# can i put the loop1 lable here? insted of upstairs?

    mov $1, %rdx //----------------------------------------------------------------------------# read 1 byt each time until you get to 0xa.
    //# each call to read will precede me in the file by the amount(number of bytes) i put to read in the function call register.

    push %rcx //# we are using %rcx as a counter, and syscall chnage him so we need to back it up and restor any time we call syscall.
    syscall
//------------------------rax not valid----------------------------------
    pop %rcx

    movb (%rsi), %dl
    cmpb $0xa , %dl // you should give cmpb 1 byte register insted of quad register // ------------if you write cmpb 0xa , %dl - it will try to go to adres 0xa, you should do $0xa beacuse is a number!

    je end_loop //# we finished read values.
  
    // not finished to read values.
    inc %rsi // -- so in the next time the value will be submitted to the right place.
    jmp loop1

end_loop:
    movq $0, (%rsi) //@@@ added (%rsi) @@@ -- put 0 in the end of the string! now it is a null-terminated string
    leaq path(%rip), %rdi //the_adres_of_a_null-terminated_string_of_leangth_8-top to atam_atol
    //movq t -????????-8(%rbp) , %rdi
    //#------------backup registers if u need to.
    push %rbx
    call atam_atol
    pop %rbx
    movq %rax, %r15

    //---------------------r15 in use to be number of byts need to read from file now-------------------

    cmpq $0, %r15
    je end //# if there is nothing to read

    movq $0, %rcx // initializing the counter for the read iterations to zero?
    movq %rbx , %rsi // the place in codeworld we need to put values to in this iteration.
    movq %r14 , %rdi // rdi now contain the right fd of the file.
  // ----------- is the upper implementatin is absolut or its ok to do that? --------------------------

loop2:
    movq $0, %rax  // service we want is - to read! need to put insaid beacuse rax can be changed after syscall
    movq $1, %rdx // number of bits? to read.----------------------------------------------------------------byets!!!
  //--------------------------- 8 bits or 1 byet? what is the meaning of that number???------------------------
 
    push %rcx // we are using %rcx as a counter, but syscall chnage him so we need to back it up and restor any time we call syscall.
    syscall //------------------------rax not valid----------------------------------
    pop %rcx

    inc %rcx
    inc %rsi // -------------------------------------------so in the next iteration the values will be wrriten to the next place in the array?

    cmp %rcx, %r15
    jne loop2
  
    // close the file
    movq $3, %rax     // service - close
    movq %r14 , %rdi //  fd to close
    syscall         // close the file.

  // returning number of quad words.
    sar $3, %r15 //use div instead?

 end: 
    movq %r15, %rax 

    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    movq %rbp, %rsp 
    popq %rbp
    ret

//# u cant use an abxulute path, 
//# insted of doing: "Movq $path, %rax,
//# you should do Lea path(%rip), %rax"






hamming_weight:
 pushq %rbp    //  # save old value of %rbp because we are going to change it in the next command.
 movq %rsp, %rbp //# update %rbp when entering the function in order to use it as a base pointer - now %rbp point to the start of the function in the stack
 pushq %rbx
 pushq %r12
 pushq %r13
 pushq %r14
 pushq %r15

 movq $0, %r13 // how many qwords so far
 movq $0, %r14 // 8 times for each qword
 movq $0, %r15 // how many 1's so far

 cmp %r13, %r12 // if there is 0 qwords so we will return 0.
 je finised_reading

main_loop:
  leaq (%rdi, %r13, 8), %r9 //address of codeword current word
  movq (%r9, %r14, 1), %r9
  cmpq $8, %r14
  inc %r14
  je qword_finished
  
qword_loop:
  cmpq $0, %r9
  je qword_finished
  test $1, %r9
  jz bit_zero_value
  inc %r15
bit_zero_value:
    shr $1, %r9
    jmp qword_loop

qword_finished:
  movq $0, %r14
  inc %r13
  cmp %r13, %rsi // finished reading words
  je finised_reading
  jmp main_loop

finised_reading:
  movq %r15, %rax //returning number of ones in codeword.
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %rbx

  movq %rbp, %rsp 
  popq %rbp
  ret





negate_first_k:

  pushq %rbp  // save old value of %rbp because we are going to change it in the next command.
  movq %rsp, %rbp // update %rbp when entering the function in order to use it as a base pointer - now %rbp point to the start of the function in the stack
  pushq %rbx
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15

  pushq %rdi // put codeword in stack
  xor %r8, %r8 // current byte to neg
  movq $0, %r9 // in-byte index

  neg_loop:
  mov %rsi, %rax
  movq $0, %rdx // num of bits to neg in byte
  movq $8, %rcx
  div %rcx // after div %rdx has num of bits to negate in current byte
  cmp $0, %rax // check if quotient is 0
  je last_byte_neg
  movb (%rsp, %r9, 1), %r8b
  not %r8b
  movb %r8b, (%rsp, %r9, 1)
  inc %r9
  sub $8, %rsi
  jmp neg_loop

  last_byte_neg:
  cmp $0, %rdx // check if remainder is 0
  je neg_finish
  
  movq $8, %rcx
  sub %rdx, %rcx
  movb (%rsp, %r9, 1), %r8b
  movq $0xff, %r10
  shrb %cl, %r10b
  xorb %r10b, %r8b 
  movb %r8b, (%rsp, %r9, 1)
  
  neg_finish:
  popq %rax // return codeword of %rdi in stack to %rax
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %rbx

  movq %rbp, %rsp 
  popq %rbp
  ret

  
bring_balance_to_the_word:
  pushq %rbp  // save old value of %rbp because we are going to change it in the next command.
  movq %rsp, %rbp // update %rbp when entering the function in order to use it as a base pointer - now %rbp point to the start of the function in the stack
  pushq %rbx
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15

  movq $0, %rdx // counter of bytes
  movq $0, %r8 // i - counter of bytes
  movq $0, %r15 // pairity iteration counter
  movq %rdi, %r12 // address of codeword
  movq %rsi, %r13 // length in qwords
  
  bal_loop:
  movq %r13, %rsi
  movq %r12, %rdi
  call hamming_weight
  movq %r13, %r14
  imul $32, %r14
  cmpq %rax, %r14 // check if num of 1's equals to half of codeword's len
  je balanced

  movq %r15, %rcx
  and $1, %rcx
  jnz no_bits_inc
  inc %r8 //i++
  no_bits_inc:
  inc %r15
  movq %r8, %rax // now we neg k bits
  movq $64, %rbx
  movq $0, %rdx
  div %rbx
  movq $0, %r11 // iterator for qwords
  movq %rax, %rbx // num of qwords

  qword_bal:
  cmp %rbx, %r11 // check if current qword is last
  je bal_last_qword
  movq (%r12, %r11, 8), %rdi
  not %rdi
  movq %rdi, (%r12, %r11, 8) // write change to mem
  inc %r11
  jmp qword_bal

  bal_last_qword:
  cmpq $0, %rdx // check if there are no more bytes
  je bal_loop
  movq (%r12, %r11, 8), %rdi //negate %rdx num of bits
  movq %rdx, %rsi

  pushq %rdi
  pushq %rsi
  pushq %rdx
  pushq %rcx
  pushq %r8
  pushq %r9
  pushq %r11
  call negate_first_k
  popq %r11
  popq %r9
  popq %r8
  popq %rcx
  popq %rdx
  popq %rsi
  popq %rdi
  
  movq %rax, (%r12, %r11, 8)
  jmp bal_loop

  balanced:
  movq %r8, %rax
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %rbx

  movq %rbp, %rsp 
  popq %rbp
  ret






