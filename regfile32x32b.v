///////////////////////////////////////////////////////////////////////
// Register File - 32 x 32-bit registers
// Three ports:
//     A - read
//     B - read
//     C - write
// outA and outB always output the register selected by inputs
// addrA and addrB, respectively.  Use a 7ns propagation delay.
// On a positive clock edge, if load is 1, loads inC into register
// selected by addrC.  Use a 15ns propagation delay
///////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module regfile32x32b(input wire clk, input wire load,
                     input wire[4:0] addrA,  output wire[31:0] outA,
                     input wire[4:0] addrB,  output wire[31:0] outB,
                     input wire[4:0] addrC,  input  wire[31:0] inC);
    // TASK:  Create an array of thirty-two 32-bit registers.
    reg[31:0] r [31:0];

    // TASK:  Use continuous assignment statements to make outA and outB
    // always output the addrAth and addrBth registers.  Make the statements
    // have a 7ns propagation delay
    assign #7 outA = r[addrA];
    assign #7 outB = r[addrB];


    // TASK:  Whenever the clock goes from low to high, if the load input is
    // high, set register number addrC to whatever is coming in through inC.
    // Make that assignment (if it happens) have a 15ns propagation delay.
    always @(posedge clk)
    begin
      if(load) begin
        #15 r[addrC] <= inC;
      end
    end
endmodule
