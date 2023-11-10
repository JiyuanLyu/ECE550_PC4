module control (opcode, aluOp, final_opcode, Rwe, Rdst, ALUinB, ALUop, DMwe, Rwd, BR, JP);
	input [4:0] opcode, aluOp;
    output Rwe, Rdst, ALUinB, ALUop, DMwe, Rwd, BR, JP;
    output [4:0] final_opcode;

    wire [4:0] opcode;

    // Here we need to know if the operation is add, addi, sw, lw
    wire my_add, my_addi, my_sw, my_lw;
    assign my_add = (~opcode[4])&(~opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0]);//00000
    assign my_addi = (~opcode[4])&(~opcode[3])&(opcode[2])&(~opcode[1])&(opcode[0]);//00101
    assign my_sw = (~opcode[4])&(~opcode[3])&(opcode[2])&(opcode[1])&(opcode[0]);//00111
    assign my_lw = (~opcode[4])&(opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0]);//01000

    // Here we need to know if the operation is bne, j, jal, jr, blt, bex, setx
    wire my_bne, my_j, my_blt;
    assign my_bne = (~opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(~opcode[0]);//00010
    assign my_j = (~opcode[4])&(~opcode[3])&(~opcode[2])&(~opcode[1])&(opcode[0]);//00001
    //assign my_jal = (~opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(opcode[0]);//00011
    //assign my_jr = (~opcode[4])&(~opcode[3])&(opcode[2])&(~opcode[1])&(~opcode[0]);//00100
    assign my_blt = (~opcode[4])&(~opcode[3])&(opcode[2])&(opcode[1])&(~opcode[0]);//00110
    assign my_bex = (opcode[4])&(~opcode[3])&(opcode[2])&(opcode[1])&(~opcode[0]);//10110
    //assign my_setx =(opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(~opcode[0]);//10101

    // Find the final ALU opcode
    // If is R-type (opcode = 00000), then final code is aluOp
    // If is addi (opcode = 00101), then final code is 00000 (add)
    assign final_opcode = my_addi ? 5'b00000 : my_add ? aluOp : opcode;

    // Define 8 signal
    or myRwe (Rwe, my_add, my_addi, my_lw);
    assign Rdst = my_sw;
    or myALUinB (ALUinB, my_addi, my_lw, my_sw);
    assign ALUop = my_bne|my_blt|my_bex; 
    assign DMwe = my_sw;
    assign Rwd = my_lw;
    assign BR = my_bne|my_blt;
    assign JP = my_j;
endmodule
