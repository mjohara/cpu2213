//////////////////////////////////////////////////////////////////////
// rom_128Kx32b - 16M RAM module for 32-bit data bus
// 4 ports:
//     en - input, 1 bit. If en is 0, module should change and output nothing
//     rw - input, 1 bit. If set to 1, something is trying to write to memory
//     addr - input 24 bits. Address of current 4-byte element.
//     dataOut - output, 32 bits. Where this memory should output data.
// If enabled, this module should do something different depending on rw:
//     if rw = 1, it should output the 4 bytes starting at addr to dataOut
//     if rw = 0, it should do nothing (notes error in simulator)
// If disabled, it should cut itself off from dataOut
//
// Educational Points:
//     - Notice that when the device shouldn't be outputting anything, 
//       it cuts itself off by setting the output line to all z's (high 
//       impedance) to prevent having multiple devices writing values 
//       to a wire at the same time.
//     - An always block with a condition defines a task that will
//       begin running if: a) the condition happens; and b) it is 
//       not already running.  In this example, the always block 
//       happens whenever en, rw, or addr have a change in value.  
///////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module rom_128Kx32b(input  wire en, 
                   input  wire rw,
                   input  wire[16:0] addr, 
                   output wire[31:0] dataOut);
    reg[7:0] values[0:(2**17-1)];   // The RAM data
    reg[31:0] outval;               // Value to be output from RAM

    // If enabled and being read, output whatever is in "outval".
    // Otherwise, block off the connection to dataOut (set to high impedance)
    assign dataOut = (en & rw) ? outval : 32'bz;

    // Whenever en, rw, or addr change...
    always @(en or rw or addr) begin
        #1   // Pause very briefly.  Without this, certain signals can
             // be both true and false at the same time, causing problems

        // If enabled and being written to, just complain
        if (en & ~rw) 
            $display("Invalid write at %d\n", addr);

        // If enabled and being read, set outval to 4 bytes at addr
        if (en & rw) 
            outval <= { values[addr], values[addr+1],
                        values[addr+2], values[addr+3] };
    end

    // At the beginning, set outval to 0, and initialize data to rom1_data.mem
    initial begin
        outval <= 32'h00000000;
        $readmemh("rom1_data.mem", values);
    end
endmodule
