`timescale 1ns/1ns

module system();
    wire clk;                 // Wire carrying the clock signal
    wire rw;                  // Wire carrying rw signal from CPU
    wire[31:0] address_bus;   // Wires carrying memory address
    wire[31:0] data_to_mem;   // Wires carrying memory address
    wire[31:0] data_from_mem; // Wires carrying memory address
    wire en1, en2, en3, en4;  // Wires carrying bus selector's enable signals

    reg reset;   // Going to simulate a reset switch that is on for a 
                 // short time at the start of the simulation.

    // Declare a clock called system_clock, and attach it to the clk wire
    clock system_clock(clk);

    // Declare a cpu called 'processor', and connect it to other devices
    cpu processor(clk, reset, rw, address_bus, data_from_mem, data_to_mem);

    // Declare a bus selector, and connect it to address and enable lines
    bus_selector selector(address_bus, en1, en2, en3, en4);

    // Declare memories, and attach to busses and enable lines
    rom_128Kx32b rom1(en1, rw, address_bus[16:0], data_from_mem);
    ram_128Kx32b ram1(en2, rw, address_bus[16:0], data_to_mem, data_from_mem);
    ram_128Kx32b ram2(en3, rw, address_bus[16:0], data_to_mem, data_from_mem);

    // Declare an output terminal, and attach to busses and enable line
    terminal term1(clk, en4, rw, address_bus[2:0], data_to_mem, data_from_mem);

    initial begin
        $dumpfile("waveform.vcd");   // Dump waveform data to waveform.vcd
        $dumpvars(1,system);         // Dump all vars in this module
        $dumpvars(1,processor);      // Dump all vars in 'processor'
   
        reset <= 1; #500             // Press the reset switch for 500ns
        reset <= 0;  
    end

    // Whenever the halted signal goes high in the processor, 
    // shortly after, we should dump out the contents of the two 
    // RAM modules to files, and then end the simulation.
    always @(posedge processor.halted) begin
        #50
        $writememh("ram1_final_contents.mem", system.ram1.values);
        $writememh("ram2_final_contents.mem", system.ram2.values);
        $finish;
    end 
endmodule
