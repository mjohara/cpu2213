`timescale 1ns/1ns

module branch_tester(input wire[10:0] opcode, input wire[31:0] flags,
                     output reg take_branch);
    // NOTE: Although you can do everything in the always block below, it
    // can be useful to use a continuous assignment statement to calculate
    // something that is an operation that gets done repeatedly.  You might
    // want to do that here using continous assignment before the always block.
    // You don't have to, but it might make your code easier.
    wire[31:0] zeop;
    assign zeop = {28'b0,opcode[3:0]};


    // This is triggered whenever opcode or flags changes.
    always @(opcode or flags) begin
        #1
          // This delay is needed here.
          // Waits until opcode's or flags' value has finished changing.
          // If this short delay isn't there, it would be hard to figure
          // out why things weren't calculating the values you expect.

        // TASK:  Implement the logic in the table in "Format of Instrutions",
        // in the Branching Instructions section.  Depending on what's in
        // opcode[5:4], you'll set take_branch based on a different formula,
        // as described in the table.  This is just a if/else if/... or a case
        // statement.

          if(((opcode[5:4] == 2'b00) && ((zeop & flags) != 0)) ||
             ((opcode[5:4] == 2'b01) && ((zeop & flags) == 0)) ||
             ((opcode[5:4] == 2'b10) && ((zeop & flags) == zeop)) ||
             ((opcode[5:4] == 2'b11) && ((zeop & (~flags)) == zeop))) begin
              take_branch <= 1;
          end
          else begin
            take_branch <= 0;
          end
    end
endmodule
