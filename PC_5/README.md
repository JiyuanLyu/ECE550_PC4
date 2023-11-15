# ECE 550 Project Checkpoint 5
Name: Jiyuan(Chelsea) Lyu, Jieying Zhang  
netID: jl1230, jz450  

In this checkpoint, is to design and simulate a single-cycle 32-bit processor, using Verilog. It including 11 different modules and detailed description list below.  

## skeleton  
This a **top-level** module that acts as a wrapper for a processor design, connecting it to instruction and data memory, as well as a register file. It including four different output clock (`imem_clock`, `dmem_clock`, `processor_clock`, and `regfile_clock`) allocated for different parts of the processor.  The imem_clock is intended for the instruction memory (IMEM), dmem_clock for the data memory (DMEM), processor_clock for the processor, and regfile_clock for the register file.  

## regfile
This module is define the **regifile** and it used to perform register read and write operations on the rising edge of the clock or during a reset condition. It operates on a set of **32 registers, each 32 bits wide**, allowing for read, write, and reset operations.  It triggers write operations on the rising edge of the clock, based on control signals `ctrl_writeEnable` and `ctrl_writeReg`, to write the specified data `data_writeReg` into the corresponding register. Additionally, it supports read operations, triggered by control signals `ctrl_readRegA` and `ctrl_readRegB`, to read data from the register file and output the results to `data_readRegA` and `data_readRegB`. And it will reset by the control signal `ctrl_reset`.  

## alu
This module is define the **alu** and it used to perform various arithmetic and logical operations. It has two **32-bit operands** (`data_operandA` and `data_operandB`) and **control signals** (`ctrl_ALUopcode` and `ctrl_shiftamt`). According to on the value of `ctrl_ALUopcode`, alu supports multiple operations(add, sub, and, or, sll, sra).  

## clk_div
This module define a **clock** module(`clk_div`), that takes an input clock signal (`clk`) and generates an output clock signal (`clk_out`) with a reduced frequency by using an internal counter and can initialization via a reset signal (`reset`). It switches the polarity of the clock signal at the end of each frequency division cycle to generate the clock output signal after the component frequency.  

## dffe
This module defines a **D flip-flop**, which is used to store a single bit of data under a rising-edge triggered clock signal. The module includes input ports for data (`d`), clock (`clk`), enable (`en`), clear (`clr`), and an output port for the stored data (`q`). On the rising edge of the clock or a rising edge of the clear signal, depending on the states of the clear and enable signals, it can set the output data q to the input data d or clear it to zero. This type of D flip-flop is commonly used in digital circuit design for data storage and timing control applications.

## pc_register
This Verilog code defines a module named **pc_register** designed to create a 32-bit program counter register file. Inside this module, a `generate` construct is employed to iteratively instantiate 32 D flip-flop (DFF) instances. Each DFF instance, named dffe_pc, is connected to an input data bit (pc_in[i]), an output data bit (`pc_out[i]`), a clock signal (`clock`), an enable signal (`en`), and a reset signal (`reset`). As a result of this approach, the code generates 32 such DFF instances within a loop, creating a 32-bit register file. This register file is capable of concurrently storing 32-bit program counter data.  

## control
This module, named **control**, takes inputs `opcode` and `aluOp` and identifies different instruction types, including add, addi, sw, lw, bne, j, jal, jr, blt, bex, and setx using logical operations. Based on the instruction type, it determines the final ALU operation code `final_opcode`, controls whether to write to registers (Rwe), the destination register write (Rdst), ALU input B (ALUinB), whether to perform a comparison operation (ALUop), memory write enable for data storage (DMwe), register write data (Rwd), BR and JP among other data path signals.

## sx 
This module defines a **sx**. The purpose is to extend a 17-bit input signal `a` to a 32-bit output signal `out`, where the high 15 bits are extended with a sign extension.  

## processor 
The **processor** module represents a basic processor architecture with components for instruction fetch, decode, execute, memory access, and write back.  It includes interfaces for instruction memory (`imem`), data memory (`dmem`), and a register file (`regfile`).  The module takes in control signals, clock, and reset inputs, and provides outputs for memory addresses, data, write enables, and control signals for the register file.  
**Decode**: Parse instructions to extract information such as opcodes, ALU opcodes, target registers, etc., and generate control signals, including write enable (`Rwe`), read register addresses (`ctrl_readRegA` and `ctrl_readRegB`). Decodes the opcode and aluOp from the instruction fetched. Derives control signals for various operations using the `control` module.  
**Execute**: Utilizes the ALU to perform operations such as addition, subtraction, and logical operations. Handles conditional branches (bne and blt) and overflow conditions.  
**Memory**: Access data Memory (`dmem`) based on the results of the ALU, including address calculation, data writing, and data reading.    
**Fetch**: Fetch instructions through the program counter (PC), pass the PC address to the instruction memory (`imem`) and fetch instructions. 
**Write (write back)** : Write data back to the regfile according to the control signal, including write enable, write register address, and write data.  
Now this is a full-processor, it can implement add, addi, sub, and, or, sll, sra, sw, lw, j, bne, jal, jr, blt, bex and setx.


