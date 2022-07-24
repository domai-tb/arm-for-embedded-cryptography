// void encode_image(u32 width, u32 height, const u8* image_rgb, u8* output);
encode_image:
    push   {r4, r5, r6, r7, r8, r9, r10, r11, lr}
    sub    sp, sp, #12                  // reserve 12 byte memory on stack
    mov    r6, r0                       // R6 := width
    mov    r5, r1                       // R5 := heigth
    mov    r10, r2                      // R10 := image_rgb
    mov    r8, r3                       // R8 := output
    uxtb   r1, r1                       // R1 := "lowest byte of height"
    movs   r0, #171                     // R0 := 171
    bl     unknown_function_2           // local = unknown_function_2(R0, R1)
    str    r0, [sp, #4]                 // R0 := "lowest 4 Byte of stack"
    str    r6, [r8]                     // output[0] = width
    str    r5, [r8, #4]                 // output[4] = height
    add    r4, r8, #8                   // R4 := output[1]
    mul    r9, r6, r5                   /* R11 := width * heigth * 3
    adds   r11, r9, r9, lsl #1          /* => image_rgb size             */
    beq    .L4                          // branch when image_size = 0
    add    r6, r10, #-1                 // R6 := image_rgb - 1
    add    r11, r11, r6                 // R11 := image_size += image_rgb - 1 = "address of last bit in image_rgb"
    movs   r5, #0                       // R5 := 0 = i
    rsb    r10, r10, #1                 // R10 := 1 - start address of image_rgb
    b      .L8
.L16:
    bl     get_random_byte              /* output[i+1]  = get_random_byte()
    strb   r0, [r4, r5]                 /*                                  */
    adds   r5, r5, #1                   // i++  => each fourth byte is random byte
    b      .L5
.L6:
    ldr    r1, [sp, #4]                 /*
    bl     unknown_function_2           /*  output[i+1] := unknown_function_2(R0, local)
    strb   r0, [r4, r5]                 /*                                               */
.L7:
    adds   r5, r5, #1                   // i++
    cmp    r6, r11                      /*
    beq    .L4                          /* while ( !last_byte )
.L8:
    add    r7, r10, r6                  // R10 + R06 = 0 (first iteration)
    tst    r5, #3                       /* branch if ((R5 & 3) == 0) */
    beq    .L16                         /* => last two bits are set  */
.L5:
    ldrb   r0, [r6, #1]!                // R0 := *(image_rgb - 1 + 8)
    subs   r0, r0, #13                  // R0 := *(image_rgb + 7) - 13
    uxtb   r0, r0                       // store lowest byte of R0
    and    r7, r7, #7                   /* R7 := R7 & 7
    cmp    r7, #3                       /* branch if ((R7 & 7) == 3)
    beq    .L6                          /*                            */
    strb   r0, [r4, r5]                 // store result to output[i+1]
    b      .L7
.L4:                                    // do ...
    lsls   r9, r9, #2                   // R9 := width * heigth * 4
    beq    .L3                          // branch if (R9 = 0) => just two most significant bits are set
    mov    r5, r4                       // i = output[1]
    add    r6, r8, r9                   // R6 := output + width * heigth * 4 => after last byte of output
    adds   r6, r6, #8                   // R6 := address of output_size + 1
.L10:                                   // do ...
    adds   r1, r4, #1                   /*
    mov    r0, r4                       /*  unknown_function_1( i, i+1 )
    bl     unknown_function_1           /*                                                   */
    adds   r4, r4, #2                   // R4 := *(output[1]+2)
    cmp    r4, r6                       /*
    bne    .L10                         /*  while ( R4 != R6 )                 */
    cmp    r9, #1                       /*
    bls    .L3                          /*  branch if ( width * higth <= 1 ) */
    add    r8, r8, #7                   /*
    add    r8, r8, r9                   /* R8 := (output + 7) + output_size */
.L11:                                   // do ...
    ldrb   r2, [r5, #1]                 // R2 := i+1
    ldrb   r3, [r5]                     // R3 := i+2
    eors   r2, r2, r3                   // R2 := i+1 XOR i+2
    strb   r2, [r5, #1]!                // i+1 := R2
    cmp    r8, r5                       /*
    bne    .L11                         /* while ( output[1] != R8 ) */
.L3:
    add    sp, sp, #12
    pop    {r4, r5, r6, r7, r8, r9, r10, r11, pc}



unknown_function_1:
    /*
        swap output[i], output[i+1]
    */
    ldrb   r3, [r0]                         // R3 := output[i]
    ldrb   r2, [r1]                         // R2 := *(output[i]+1)
    eors   r3, r3, r2                       // R3 := R3 XOR R2
    strb   r3, [r0]                         // output[i] = output[i] XOR *(output[i]+1)
    ldrb   r2, [r1]                         // R2 := *(output[i]+1)
    eors   r3, r3, r2                       // R3 := *(output[i]+1) XOR output[i] XOR *(output[i]+1)
    strb   r3, [r1]                         // *(output[i]+1) = output[i]
    ldrb   r2, [r0]                         // output[i] = *(output[i]+1)
    eors   r3, r3, r2                       // R3 := output[i] XOR *(output[i]+1)
    strb   r3, [r0]                         // output[i] = output[i] XOR *(output[i]+1)
    bx     lr


unknown_function_2:
    /*
        return ~R0 & R1 + R0 & ~R1 = R0 XOR R1
    */
    and    r2, r0, r1
    mvn    r2, r2
    and    r3, r0, r2
    mvn    r3, r3
    and    r0, r2, r1
    mvn    r0, r0
    and    r0, r3
    mvn    r0, r0
    bx     lr
