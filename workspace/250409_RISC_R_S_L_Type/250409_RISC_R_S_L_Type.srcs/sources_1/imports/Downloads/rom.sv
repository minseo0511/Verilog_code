`timescale 1ns / 1ps

module rom (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:15];

    initial begin
        //rom[x]=32'b fucn7 _ rs2 _ rs1 _f3 _ rd  _opcode; // R-Type
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x2, x1 23
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; // sub x5, x2, x1 1

        //rom[x]=32'b imm7 _ rs2 _ rs1 _f3 _ imm5  _opcode; // S-Type
        rom[2] = 32'b0000000_00010_00000_010_01000_0100011; // sw M(rs1+imm) = rs2 -> M(2) = 12

        //rom[x]=32'b imm12 _ rs1 _ f3 _ rd _opcode; // L-Type
        rom[3] = 32'b000000001000_00000_010_00010_0000011; // lw rd = M(rs1+imm) -> reg[2] = M(0+2) = 12

        //rom[x]=32'b imm12 _ rs1 _ f3 _ rd _opcode; // I-Type
        rom[4] = 32'b010000000001_00010_000_00100_0010011; // ADDI x4 = imm(1025) + x2(12) = 1037
        //rom[x]=32'b imm7_shamt5 _ rs1 _ f3 _ rd _opcode; // I-Type
        rom[5] = 32'b0000000_00010_00010_001_00100_0010011; // SLLI x4 = x2(12) << shmat(2)  = 0000_1100 -> 0011_0000
        //rom[x]=32'b imm7_shamt5 _ rs1 _ f3 _ rd _opcode; // I-Type
        rom[6] = 32'b0000000_00010_00010_101_00100_0010011; // SRLI x4 = x2(12) >> shmat(2) = 0000_1100 -> 0000_0011
        //rom[x]=32'b imm7_shamt5 _ rs1 _ f3 _ rd _opcode; // I-Type
        rom[7] = 32'b0100000_00010_11111_101_00100_0010011; // SRAI x4 = x31 >> shmat(2) = 1100_0110_0011_1100_0110_0011_1100_0110 -> 1111_0001_1000_1111_0001_1000_1111_0001 

        //rom[x]=32'b imm7 _ rs2 _ rs1 _f3 _ imm5  _opcode; // S-Type
        rom[8] = 32'b0000000_11111_00010_000_00000_0100011; // sw M(rs1+imm) = rs2 -> M(3(12)+0) = x31data
        
        //rom[x]=32'b imm12 _ rs1 _ f3 _ rd _opcode; // L-Type
        rom[9] = 32'b000000001100_00000_000_10000_0000011; // lw rd = M(rs1+imm) -> reg[16] = M(0+10) = x31data
    end
    assign data = rom[addr[31:2]];
endmodule
