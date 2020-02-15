///////////////////////////////////////////////////////////////////////
// Bus Selector / Bus Master - Based on address, enable/disable chips
// 5 ports:
//     address - input,  32-bit.
//     en1     - output, 1 bit.  1 if upper 8 bits of address = 00000000
//     en2     - output, 1 bit.  1 if upper 8 bits of address = 00000001
//     en3     - output, 1 bit.  1 if upper 8 bits of address = 00000011
//     en4     - output, 1 bit.  1 if address between 0x80000000 and 0x80000008
// Note:
//     This could have been set up as a series of gates.  Instead, 
//     a behavioural description was used (easier to read).
///////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module bus_selector(input wire[31:0] address, 
                    output wire en1,
                    output wire en2,
                    output wire en3,
                    output wire en4);

    assign en1 = (address[31:17] == 15'b000000000000000) ? 1 : 0;
    assign en2 = (address[31:17] == 15'b000000010000000) ? 1 : 0;
    assign en3 = (address[31:17] == 15'b000000110000000) ? 1 : 0;

    // Note: This is leftmost bit = 1, and all others, except last 3 bits,
    // are 0.  Device this is attached to only use 8 bytes of address space
    assign en4 = ((address[31] == 1) && (address[30:3] == 0)) ? 1 : 0;

endmodule
