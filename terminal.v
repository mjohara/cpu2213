/////////////////////////////////////////////////////////////////////
// terminal - Simple 1-character-at-a-time output terminal
// 6 ports:
//     clk - input, 1 bit. Clock signal
//     en - input, 1 bit. If en is 0, module should change and output nothing
//     rw - input, 1 bit. If set to 1, something is trying to write to memory
//     addr - input 3 bits. Address to access. Only responds to 0 and 4
//     dataIn - input, 32 bits. Data being written to device
//     dataOut - output, 32 bits. Where this memory should output data.
// If enabled, this module should:
//     if addr = 0 and rw = 1: output status (0 if ready to accept new value)
//     if addr = 0 and rw = 0: if non-zero value written, output and clear 
//                             current character.  Then set status to 0
//     if addr = 4 and rw = 1: Nothing
//     if addr = 4 and rw = 0: Set current character to lower 8 bits
// If disabled, it should cut itself off from dataOut
//
// Educational Points:
//     - It's quite common for devices to be accessed as if they're 
//       memory.  They generally expose some of their registers as
//       memory addresses.
//     - Also, it's common for devices to set up certain memory addresses
//       as triggers, where if certain values (or any values) are written,
//       it will trigger the device to take an action.
//     - Like in the memories, notice that when the device shouldn't be
//       outputting anything, it cuts itself off by setting the output
//       line to all z's (high impedance) to prevent having multiple 
//       devices writing values to a wire at the same time.
///////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module terminal(input wire clk, input wire en, input wire rw,
                input wire[2:0] addr, input wire[31:0] dataIn,
                output wire[31:0] dataOut);
    reg[31:0] outval;  // Holds value being output

    reg[31:0] status;  // Status field. This is at memory location 0.
    reg[7:0] charIn;   // Input character field. This is at memory location 4.

    // When enabled and being read, output whatever's in "outval" to dataOut.
    // Otherwise cut itself off from dataOut (set dataOut to high impedance)
    assign dataOut = (en & rw) ? outval : 32'bz;
    
    // Whenever a positive clock edge happens
    always @(posedge clk) begin
        // if enabled, and being read at address 0, output status.
        if (en & rw & addr == 0) 
            outval <= status;

        // if enabled, and being written at address 4, store lowest 8 bits
        // of dataIn to register holding character to be written.
        if (en & ~rw & addr == 4)
            charIn <= dataIn[7:0];

        // if enabled and being written at address 0 with a non-zero value,
        // store that status initially, then pause and write the character.
        // After done writing, set status back to 0, and set character to 0.
        if (en & ~rw & addr == 0 & dataIn != 0) begin
            status <= dataIn;
            #20
            if (charIn != 0) 
                $display("%c", charIn);
            charIn <= 0;
            status <= 0;
        end
    end 
endmodule

