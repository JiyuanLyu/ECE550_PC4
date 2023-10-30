module control (opcode, aluOp, final_opcode, Rwe, Rdst, ALUinB, ALUop, DMwe, Rwd);
	input [4:0] opcode, aluOp;
    output Rwe, Rdst, ALUinB, ALUop, DMwe, Rwd;
    output [4:0] final_opcode;

    wire [4:0] opcode;

    // Here we need to know if the operation is add, addi, sw, lw
    wire my_add, my_addi, my_sw, my_lw;
    assign my_add = (~opcode[4])&(~opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0]);//00000
    assign my_addi = (~opcode[4])&(~opcode[3])&(opcode[2])&(~opcode[1])&(opcode[0]);//00101
    assign my_sw = (~opcode[4])&(~opcode[3])&(opcode[2])&(opcode[1])&(opcode[0]);//00111
    assign my_lw = (~opcode[4])&(opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0]);//01000

    // Find the final ALU opcode
    // If is R-type (opcode = 00000), then final code is aluOp
    // If is addi (opcode = 00101), then final code is 00000 (add)
    assign final_opcode = my_addi ? 5'b00000 : my_add ? aluOp : opcode;

    // Define 5 signal
    or myRwe (Rwe, my_add, my_addi, my_lw);
    assign Rdst = my_sw;
    or myALUinB (ALUinB, my_addi, my_lw, my_sw);
    assign ALUop = 1'b0; // not beq yet
    assign DMwe = my_sw;
    assign Rwd = my_lw;

    //assign ALUop = beq; //not required yet
endmodule
