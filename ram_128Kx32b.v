///////////////////////////////////////////////////////////////////////
// ram128Kx32b - 128K RAM module for 32-bit data bus
// 5 ports:
//     en - input, 1 bit. If en is 0, module should change and output nothing
//     rw - input, 1 bit. If set to 1, something is trying to write to memory
//     addr - input 24 bits. Address of current 4-byte element.
//     dataIn - input, 32 bits. Data being written to memory.
//     dataOut - output, 32 bits. Where this memory should output data.
// If enabled, this module should do something different depending on rw:
//     if rw = 1, it should output the 4 bytes starting at addr to dataOut
//     if rw = 0, it should set the 4 bytes starting at addr to dataIn
// If disabled, it shouldn't change any data, and cut itself off from dataOut
//
// Educational Points:
//     - Notice that when the device shouldn't be outputting anything, 
//       it cuts itself off by setting the output line to all z's (high 
//       impedance) to prevent having multiple devices writing values 
//       to a wire at the same time.
///////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module ram_128Kx32b(input  wire en, 
                   input  wire rw,
                   input  wire[16:0] addr, 
                   input  wire[31:0] dataIn,
                   output wire[31:0] dataOut);
    reg[7:0] values[0:(2**17-1)];   // The RAM data
    reg[31:0] outval;               // Value to be output from RAM

    // If enabled and being read, output whatever is in "outval".
    // Otherwise, block off the connection to dataOut (set to high impedance)
    assign dataOut = (en & rw) ? outval : 32'bz;

    // Whenever en, rw, or addr change...
    always @(en or rw or addr) begin
        #1   // Pause very briefly

        // If enabled and being written to, set 4 bytes at addr to dataIn
        if (en & ~rw) begin  
            values[addr+0] <= dataIn[31:24];
            values[addr+1] <= dataIn[23:16];
            values[addr+2] <= dataIn[15:8];
            values[addr+3] <= dataIn[7:0];
            end

        // If enabled and being read, set outval to 4 bytes at addr
        if (en & rw)
            outval <= { values[addr], values[addr+1],
                        values[addr+2], values[addr+3] };
    end

    // At the beginning, set outval to 0.
    initial begin
        outval <= 32'h00000000;
    end
endmodule

