`timescale 1ns/1ns

module instruction_decoder(input wire[31:0] ir,
                           output wire[10:0] opcode,
                           output wire type_math_flow,
                           output wire type_branch,
                           output wire type_set_flag_value,
                           output wire type_halt,
                           output wire[4:0] regIn,
                           output wire[4:0] regA,
                           output wire[4:0] regB,
                           output wire[31:0] imm1_ze,
                           output wire[31:0] imm1_se,
                           output wire[31:0] imm2_ze,
                           output wire[31:0] imm2_se,
                           output wire[31:0] imm3_se,
                           output wire[1:0] regIn_source,
                           output wire[1:0] aluB_source,
                           output wire mem_rw,
                           output wire[3:0] alu_op);

    // TASK: Use continuous assignment statements to implement all the outputs.
    // See the project documentation for more information about how to calculate
    // the outputs.
    assign opcode = ir[31:21];

    assign regIn_source = opcode[9:8];
    assign aluB_source = opcode[7:6];
    assign mem_rw = opcode[5];
    assign alu_op = opcode[3:0];

    assign type_math_flow = (opcode[10] == 1'b0) ? 1 : 0;
    assign type_branch = (opcode[10:8] == 3'b100) ? 1 : 0;
    assign type_set_flag_value = (opcode[10:6] == 5'b10100) ? 1 : 0;
    assign type_halt = (opcode[10:0] == 11'b11111111111) ? 1 : 0;

    assign regIn = (type_branch && (opcode[7] == 1)) ? 5'b11111 : ir[20:16];

    assign regA = ir[15:11];
    assign regB = ir[10:6];

    assign imm1_ze = {16'b0, ir[15:0]};
    assign imm1_se = {{16{ir[15]}}, ir[15:0]};
    assign imm2_ze = {21'b0, ir[10:0]};
    assign imm2_se = {{21{ir[10]}}, ir[10:0]};
    assign imm3_se = {{21{ir[20]}},{ir[20:16], ir[5:0]}};

endmodule
