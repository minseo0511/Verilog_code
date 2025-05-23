`timescale 1ns / 1ps

module rom (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:127];

    initial begin
    /*
        //rom[x]=32'b fucn7 _ rs2 _ rs1 _f3 _ rd  _opcode; // R-Type
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; // sub x5, x2, x1
        //rom[x]=32'b imm7  _ rs2 _ rs1 _f3 _ imm5_ opcode; // B-Type
        rom[2] = 32'b0000000_00010_00010_000_01100_1100011; // beq x2, x2, 12 
        //rom[x]=32'b imm7  _ rs2 _ rs1 _f3 _ imm5_ opcode; // S-Type
        rom[3] = 32'b0000000_00010_00000_010_01000_0100011; // sw x2, 8(x0);
        //rom[x]=32'b imm12      _ rs1 _f3 _ rd  _ opcode; // L-Type
        rom[4] = 32'b000000001000_00000_010_00011_0000011; // lw x3, 8(x0);
        //rom[x]=32'b imm12      _ rs1 _f3 _ rd  _ opcode; // I-Type
        rom[5] = 32'b000000000001_00000_000_00001_0010011; // addi x1, x0, 1;
        rom[6] = 32'b000000000010_00001_001_00110_0010011; // slli x6, x1, 2;
    */   
    
    //rom[x]=32'b fucn7 _ rs2 _ rs1 _f3 _ rd  _opcode; // R-Type
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; // sub x5, x2, x1
        //rom[x]=32'b imm7  _ rs2 _ rs1 _f3 _ imm5_ opcode; // B-Type
        rom[2] = 32'b0000000_00010_00010_000_01100_1100011; // beq x2, x2, 12 
        //rom[x]=32'b imm7  _ rs2 _ rs1 _f3 _ imm5_ opcode; // S-Type
        rom[3] = 32'b0000000_00010_00000_010_01000_0100011; // sw x2, 8(x0);
        //rom[x]=32'b imm12      _ rs1 _f3 _ rd  _ opcode; // L-Type
        rom[4] = 32'b000000001000_00000_010_00011_0000011; // lw x3, 8(x0);
        //rom[x]=32'b imm12      _ rs1 _f3 _ rd  _ opcode; // I-Type
        rom[5] = 32'b000000000001_00000_000_00001_0010011; // addi x1, x0, 1;
        rom[6] = 32'b000000000010_00001_001_00110_0010011; // slli x6, x1, 2;
      
        //rom[x]=32'b fucn7 _ rs2 _ rs1 _f3 _ rd  _opcode; // R-Type_1
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; // sub x5, x2, x1
        rom[2] = 32'b0000000_00001_00010_100_00110_0110011; // xor x6, x2, x1
        rom[3] = 32'b0000000_00001_00010_110_00111_0110011; // or x7, x2, x1
        rom[4] = 32'b0000000_00001_00010_111_01000_0110011; // and x8, x2, x1

        
        //rom[x]=32'b fucn7 _ rs2 _ rs1 _f3 _ rd  _opcode; // R-Type_2
        rom[5] = 32'b0000000_00001_11111_001_00100_0110011; // sll x4, x1, x31
        rom[6] = 32'b0000000_00010_11111_101_00101_0110011; // srl x5, x2, x31
        rom[7] = 32'b0100000_00001_11111_101_00110_0110011; // sra x6, x1, x31
        rom[8] = 32'b0000000_00001_00010_010_00111_0110011; // slt x7, x2, x1
        rom[9] = 32'b0000000_00010_00001_011_01000_0110011; // sltu x8, x2, x1

        //rom[x]=32'b imm7   _rs2  _rs1 _f3 _imm5  _opcode // B-Type
        rom[10] = 32'b0000000_00010_00010_000_01000_1100011; // beq x2, x2, 8 
        rom[11] = 32'b0000000_00010_00010_001_01100_1100011; // bne x2, x2, 12
        rom[12] = 32'b0000000_11111_00100_100_10000_1100011; // blt x4, x31, 16
        rom[13] = 32'b0000000_00110_00010_101_01000_1100011; // bge x6, x2, 8
        rom[14] = 32'b0000000_11111_00100_110_01100_1100011; // bltu x4, x31, 12
        rom[15] = 32'b0000000_00010_00010_111_10000_1100011; // bgeu x2, x2, 16
        
        //rom[x]=32'b imm7  _ rs2 _ rs1 _f3 _ imm5_ opcode; // S-Type
        rom[16] = 32'b0000000_11111_00000_000_01001_0100011; // sb x31, x0, 9;
        rom[17] = 32'b0000000_11111_00000_001_01010_0100011; // sh x31, x0, 10;
        rom[18] = 32'b0000000_11111_00001_010_00000_0100011; // sw x31, x1, 0;
        
        //rom[x]=32'b imm12      _ rs1 _f3 _ rd  _ opcode; // L-Type
        rom[19] = 32'b000000001010_00000_000_00101_0000011; // lb x5, 10(x0);
        rom[20] = 32'b000000001010_00000_001_00110_0000011; // lh x6, 10(x0);
        rom[21] = 32'b000000001010_00000_010_00111_0000011; // lw x7, 10(x0);
        rom[22] = 32'b000000001010_00000_100_01000_0000011; // lbu x8, 10(x0);
        rom[23] = 32'b000000001010_00000_101_01001_0000011; // lhu x9, 10(x0);
        
        // i-type
        //addi x3, x2, 8      => x3 = 12 + 8 = 20
        rom[24] = 32'b000000001000_00010_000_00011_0010011; 
        // slti x4, x2, 10     => x4 = (12 < 10) ? 1 : 0 => 0
        rom[25] = 32'b000000001010_00010_010_00100_0010011; 
        // sltiu x5, x2, 15    => x5 = (12 < 15) ? 1 : 0 => 1
        rom[26] = 32'b000000001111_00010_011_00101_0010011; 
        // xori x6, x2, 5      => x6 = 12 ^ 5 = 9
        rom[27] = 32'b000000000101_00010_100_00110_0010011;
        // ori x7, x2, 2       => x7 = 12 | 2 = 14
        rom[28] = 32'b000000000010_00010_110_00111_0010011;
        // andi x8, x2, 6      => x8 = 12 & 6 = 4
        rom[29] = 32'b000000000110_00010_111_01000_0010011; 
        // slli x9, x2, 1      => x9 = 12 << 1 = 24
        rom[30] = 32'b0000000_00001_00010_001_01001_0010011;
        // srli x10, x2, 2     => x10 = 12 >> 2 = 3
        rom[31] = 32'b0000000_00010_00010_101_01010_0010011; 
        // srai x11, x2, 2     => x11 = 12 >>> 2 = 3 (signed arithmetic shift)
        rom[32] = 32'b0100000_00010_00010_101_01011_0010011; 
        
        //rom[x]=32'b imm20              _ rd  _ opcode; // LU-Type
        rom[33] = 32'b11000110001101101100_00111_0110111; // lui x7 = '1' << 12;
        
        //rom[x]=32'b imm20              _ rd  _ opcode; // LU-Type
        rom[34] = 32'b11000110001101101100_01000_0010111; // lui x8 =  PC + (''<<12);
        
        //rom[x]=32'b imm20              _ rd  _ opcode; // J-Type
        rom[35] = 32'b00000000100000000000_01001_1101111; // jal x9 = PC + 4, PC = PC + imm(8);
        
        //rom[x]=32'b imm12       _ rs1 _f3 _ rd  _ opcode; // JL-Type
        rom[37] = 32'b000000010100_00010_000_01010_1100111; // jalr x10 = PC + 4, PC = rs1(2(12)) + imm(20) = 32(8);
        
        //rom[x]=32'b imm12       _ rs1 _f3 _ rd  _ opcode; // JL-Type
        rom[39] = 32'b000000000110_00000_000_01010_1100111; // jalr x10 = PC + 4, PC = rs1(2(12)) + imm(12) = 24(6);
        
        //rom[x]=32'b imm7  _ rs2 _ rs1 _f3 _ imm5_ opcode; // S-Type
        rom[41] = 32'b0000000_11111_00000_001_01000_0100011; // sh x31, 8(x0);
        
        //rom[x]=32'b imm12      _ rs1 _f3 _ rd  _ opcode; // L-Type
        rom[42] = 32'b000000001000_00000_000_01011_0000011; // lb x11, 8(x0);
       
        //rom[x]=32'b imm12       _ rs1 _f3 _ rd  _ opcode; // JL-Type
        rom[43] = 32'b000000000100_00010_000_01100_1100111; // jalr x12 = PC + 4, PC = rs1(x2(12)) + imm(4) = 16(4);


    // $readmemh("code.mem", rom);
    end
    assign data = rom[addr[31:2]];
endmodule
