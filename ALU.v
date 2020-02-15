`timescale 1ns/1ns

// Arithmetic Logic Unit
// This module performs a variety of math calculations, and is the
// central math unit for the CPU.
// It takes two 32-bit inputs, a and b, along with an input that
// specifies the math operation the ALU should perform.
// It also takes a carry in for the operations that use it (ADD,
// SUB).
// The main output is a 32-bit value that represents the result of
// the operation.  If an operation could create a value larger than
// 32 bits, the output will be the lowest 32 bits of the result.
//
module ALU(input wire[31:0] a,
           input wire[31:0] b,
           input wire carry_in,
           input wire[3:0] alu_op,
           output wire[31:0] out,
           output wire set_flags,
           output wire carry_out,
           output wire zero_out,
           output wire neg_out
           );

    // TASK:  Create the result register

    reg[63:0] result;

    // TASK:  Make the output always be the lowest 32 bits of the result register

    assign out = result[31:0];

    // TASK:  Make the set_flags, zero_out, neg_out, and carry_out outputs
    // be whatever values are described in the documentation.

    assign set_flags = (alu_op == 4'b0000 || alu_op == 4'b0001) ? 0 : 1;
    assign carry_out = (alu_op == 4'b1000 || alu_op == 4'b1001) ? result[32] : 0;
    assign zero_out = (out == 32'b0) ? 1 : 0;
    assign neg_out = out[31];

    // This always @() block is triggered whenever any of the 4 inputs change.
    always @(a or b or carry_in or alu_op) begin
        #1    // This delay is needed because when the inputs are changing, their
              // values don't change until just after the current time step.  If
              // this isn't here, debugging would be a pain.

        // TASK: Make it calculate the result of the intended operation, as described
        // in the documentation, and store the result in the result register.
        // Note:  The way to do signed division is   $signed(a)/$signed(b)
        //        It can be hard to find out how to do it, so I give it here.

	case(alu_op)
                4'b0000: result <= a; // no flag update
                4'b0001: result <= b; // no flag update
                4'b0010: result <= ~a;
                4'b0011: result <= {~a[31],a[30:0]};
                4'b0100: result <= a & b;
                4'b0101: result <= a | b;
                4'b0110: result <= a ^ b;
                4'b0111: result <= a & ~b;
                4'b1000: result <= a + b + carry_in;
                4'b1001: result <= a - b - 1 + carry_in;
                4'b1010: result <= a * b;
                4'b1011: result <= a % b;
                4'b1100: result <= $signed(a)/$signed(b);
                4'b1101: result <= a / b;
                4'b1110: result <= a << b;
                4'b1111: result <= a >> b;
	endcase
    end
endmodule
