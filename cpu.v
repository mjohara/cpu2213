///////////////////////////////////////////////////////////////////////
// CPU - processing unit.  Currently just a simple state machine that
//       does the following:
//
//           Initialize CPU registers to appropriate values (PC to 0x00001000,
//               flags to 0, rw to 1, addr to 0, dataOut to 0, count to 0).
//           count = 0;
//
//           Repeat until simulation finishes
//               If count == 0:
//                   - Tell memory to read data from the address in
//                     the Program Counter (PC)
//                   - count++
//               If count == 1:
//                   - if the CPU is halted, put 0x64000000 in the
//                     instruction register (IR).  Otherwise, put
//                     the data that has been returned by memory
//                     into the IR.
//                   - count++
//               If count == 2:
//                   - If it's a math or data flow operation:
//                       - Ask memory to read data from the address at
//                         Register A + SE(Imm2) (in case a MOV instruction
//                         is happening).
//                       - Put the appropriate value into the register
//                         connected to the ALU's B input.  This is based
//                         on the ALU_B_source part of the opcode.
//                         NOTE:  if it's Imm2 that is used, you have
//                         to either zero-extend or sign-extend it
//                   - count++
//               If count == 3:
//                   - Set the flags register as appropriate.
//                     NOTE: halt operations, set flag operations, and math/data
//                     flow operations might all do this.  Check the descriptions
//                     for those operations and do them in this stage of the state
//                     machine
//                   - count++
//               If count == 4:
//                   - If a value should be stored in a register, do so in this
//                     state.  NOTE: This will happen in math/data flow operations
//                     (except those where the opcode says not to), and in
//                     branching instructons that need to set register 31 (lr/r31)
//                   - count++
//               If count == 5:
//                   - Make sure the register file is told to not keep setting a
//                     value (i.e. the CPU should only set the value of a register
//                     in the register file during state 4)
//                   - If a value should be stored in memory, set the address,
//                     dataOut, and rw as appropriate to ask the memory to store
//                     the value.  Note: that only occurs during certain math/data
//                     flow operations.
//                   - count++
//               If count == 6:
//                   - Make sure the CPU stops writing to memory (in case it was
//                     writing in the previous step).  It should be done by now.
//                   - count++
//               If count == 7:
//                   - Update the Program Counter.  Normally, it will be set to
//                     PC+4, unless it is a branching instruction for which the
//                     branching condition is true (see notes on the Branch Tester)
//                   - count = 0
//
// 6 ports:
//     clk - input, 1 bit. Clock signal
//     reset - input, 1 bit.  Reset signal.  When 1 and clk goes high, reset
//     rw - output, 1 bit. Set to 1 if reading data, or 0 for writing
//     addr - output, 32 bits. Address of 4-byte element to read/write
//     dataIn - input, 32 bits. Data being read from memory
//     dataOut - output, 32 bits. Data to write to memory
///////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module cpu(input wire clk,
           input wire reset,
           output reg rw,
           output reg[31:0] addr,
           input wire[31:0] dataIn,
           output reg[31:0] dataOut);

    // Put any simple registers inside the CPU here.  Here's 4 of them
    reg[31:0] pc;                  // 32-bit register called 'addrOut'
    reg[31:0] ir;                  // 32-bit register called 'addrOut'
    reg[31:0] flags;
    reg[2:0] count;

    // TASK:  Add any other required registers here.  What other registers
    // will you need?  (refer to documentation on the CPU's structure).
    reg load_reg;
    reg[31:0] reg_data;
    reg[31:0] ALU_B;


    // TASK:  Create wires for each of the 4 known flags, and connect them
    // to the appropriate bits in the flags register.  Why?
    //     1. It makes it easier to refer to them in the rest of the code.
    //     2. The system this is part of REQUIRES a "halted" signal somewhere
    //        in the CPU.  One of the items in Flags provides this.
    wire zero;
    wire negative;
    wire carry;
    wire halted;

    assign zero = flags[0];
    assign negative = flags[1];
    assign carry = flags[2];
    assign halted = flags[31];


    // TASK:  Create Wires to represent the values coming out of the
    // instruction decoder.  It's convenient to name them the same as
    // what they're called in the instruction_decoder module
    wire[10:0] opcode;
    wire type_math_flow;
    wire type_branch;
    wire type_set_flag_value;
    wire type_halt;
    wire[4:0] regIn;
    wire[4:0] regA;
    wire[4:0] regB;
    wire[31:0] imm1_ze;
    wire[31:0] imm1_se;
    wire[31:0] imm2_ze;
    wire[31:0] imm2_se;
    wire[31:0] imm3_se;
    wire[1:0] regIn_source;
    wire[1:0] aluB_source;
    wire mem_rw;
    wire[3:0] alu_op;

    // TASK:  Create wires for the two outputs from the register file
    wire[31:0] reg_outA;
    wire[31:0] reg_outB;

    // TASK:  Create wires for the outputs from the ALU.  Name them nicely
    // appropriate things.
    wire[31:0] alu_out;
    wire alu_set_flags;
    wire alu_carry_out;
    wire alu_zero_out;
    wire alu_neg_out;


    // TASK:  Add an instruction decoder.  Connect its input to the
    // instruction register, and its outputs to the appropriate wires.
    instruction_decoder decoder(ir, opcode,
                                type_math_flow, type_branch,
                                type_set_flag_value, type_halt,
                                regIn, regA,
                                regB, imm1_ze,
                                imm1_se, imm2_ze,
                                imm2_se, imm3_se,
                                regIn_source, aluB_source,
                                mem_rw, alu_op);


    // Example of adding a register file.  Rename the inputs and outputs to
    // match whatever you used for names when creating wires and registers
    // above.
    regfile32x32b registers(clk, load_reg,
                            regA, reg_outA,
                            regB, reg_outB,
                            regIn, reg_data);


    // TASK:  add an ALU component.  Wire it's A input to the A output from
    // the register file.  Wire its B input from the register used to store
    // the input to the ALU's B input.  Connect up other wires as appropriate.
    ALU alu(reg_outA, ALU_B,
            carry, alu_op,
            alu_out, alu_set_flags,
            alu_carry_out, alu_zero_out,
            alu_neg_out);

    // I'll give this one to you, as an example of adding an instance of
    // a branch tester.  Rename "opcode" to whatever you made as the opcode
    // output from your instruction decoder.
    wire take_branch;
    branch_tester branch_test(opcode, flags, take_branch);


    // Every time the clock goes up to 1...
    always @(posedge clk) begin
        if (reset) begin
            // TASK:  Set registers to initial values (see notes at top).  This
            // essentially restarts the system.
            //(PC to 0x00001000,flags to 0, rw to 1, addr to 0, dataOut to 0, count to 0).
            pc <= 32'h00001000;
            flags <= 0;
            rw <= 1;
            addr <= 0;
            dataOut <= 0;
            count <= 0;
        end else begin
            // If not resetting, then we execute the state machine
            if (count == 0) begin
                // TASK:  Do the things described for count == 0 in the description
                // at the top of the file.
                // Tell memory to read data from the address in the Program Counter (PC)
                addr <= pc;
                count <= count + 1;
            end else if (count == 1) begin
                // TASK:  Do the things described for count == 1 in the description
                // at the top of the file.
                //                   - if the CPU is halted, put 0x64000000 in the
                //                     instruction register (IR).  Otherwise, put
                //                     the data that has been returned by memory
                //                     into the IR.
                //                   - count++
                if(halted) begin
                  ir <= 32'h64000000;
                end else begin
                  ir <= dataIn;
                end
                count <= count + 1;
            end else if (count == 2) begin
                // Do the things described for count == 2 in the description
                // at the top of the file.

                if (type_math_flow) begin   // If this is a math/data flow operation
                    // TASK:  Tell memory to read data at the address noted
                    // in the directions

                    addr <= reg_outA + imm2_se;

                    // TASK:  Set the value of the register connected to the ALU's
                    // B input.  This will be according to the ALU B Source part
                    // of the opcode.  NOTE: when imm2 is used as the input, you
                    // must use the sign-extended or the zero-extended version of
                    // imm2 as appropriate for the current alu operation.
                    // Mostly a big if.
                    if(aluB_source == 2'b00) begin
                      ALU_B <= imm1_ze;
                    end else if(aluB_source == 2'b01) begin
                      //se for add, sub, multi, signed divide
                      if(alu_op == 4'b1000 ||
                         alu_op == 4'b1001 ||
                         alu_op == 4'b1010 ||
                         alu_op == 4'b1100) begin
                        ALU_B <= imm2_se;
                      //else unsigned
                      end else begin
                        ALU_B <= imm2_ze;
                      end
                    end else if(aluB_source == 2'b10) begin
                      ALU_B <= reg_outB;
                    end else if(aluB_source == 2'b11) begin
                      ALU_B <= flags;
                    end
                end

                count <= count + 1;
            end else if (count == 3) begin
                // By now, the ALU result is complete.

                // TASK:  Set the bits in the flags register as appropriate.
                // Math/data flow operations, set flag value operations, and
                // halt operations all do this (except certain alu operations).

                if(type_math_flow && alu_set_flags) begin
                  //carry
                  flags[2] <= alu_carry_out;
                  //zero
                  flags[0] <= alu_zero_out;
                  //negative
                  flags[1] <= alu_neg_out;
                end

                if(type_set_flag_value) begin
                  flags[opcode[4:0]] <= opcode[5];
                end

                if(type_halt) begin
                  flags[31] <= type_halt;
                end

                count <= count + 1;
            end else if (count == 4) begin
                // By now (well, even by count==3), the result of the memory op
                // will be in dataIn

                // TASK:  If a value should be stored in a register in the register
                // file, do it.  NOTE:  Math/data flow operations do this except
                // when opcode[9:8] is '11', and branching instructions sometimes
                // (look up when) store data in r31.

                if(type_math_flow && (opcode[9:8] != 2'b11)) begin
                  if(opcode[9:8] == 2'b00) begin
                    reg_data <= pc + 4;
                  end else if(opcode[9:8] == 2'b01) begin
                    reg_data <= alu_out;
                  end else if(opcode[9:8] == 2'b10) begin
                    reg_data <= dataIn;
                  end
                  load_reg <= 1;
                end

                if((opcode == 11'b10010010000) || (opcode == 11'b10011010000)) begin
                  reg_data <= pc+4;
                  load_reg <= 1;
                end

                count <= count + 1;
            end else if (count == 5) begin
                // TASK:  Tell the register file to stop trying to save a value
                // in a register
                load_reg <= 0;


                // TASK:  Ask memory to write a value at the designated location.
                // Only do this if it's a math/data from operation, and the mem_rw
                // part of the opcode is 0.
                if(type_math_flow == 1 && mem_rw == 0) begin
                  rw <= 0;
                  addr <= reg_outA + imm3_se;
                  dataOut <= reg_outB;
                end

                count <= count + 1;
            end else if (count == 6) begin
                // TASK: tell CPU to stop trying to write data to memory.  If it
                // was in the previous state, it'll be done now.  If it wasn't,
                // well, it won't hurt to still it to not write to memory.
                rw <= 1;

                count <= count + 1;
            end else if (count == 7) begin
                // TASK:  Update program counter.
                // Normally it updates to PC+4.  However, if it's a branching
                // instruction and if it's supposed to take that branch, assign
                // the appropriate value to PC (2 options as described in "Format
                // of Instructions").

                if(take_branch && type_branch) begin
                  if(opcode[6] == 0) begin
                    pc <= reg_outA; 
                  end else if(opcode[6] == 1) begin
                    pc <= pc + imm1_se;
                  end
                end else begin
                  pc <= pc + 4;
                end

                count <= 0;
            end
        end
    end

    initial begin
        // TASK:  Set registers to initial values (see notes at top).  This
        // essentially restarts the system.  This will be the same code as for
        // when a reset happens
        pc <= 32'h00001000;
        flags <= 0;
        rw <= 1;
        addr <= 0;
        dataOut <= 0;
        count <= 0;
    end

endmodule
