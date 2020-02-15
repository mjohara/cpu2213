///////////////////////////////////////////////////////////////////////
// Clock - Generates square wave clock
// One port:
//     clk - generated clock signal
// Period may be changed by editing PERIOD parameter.  Clock cycle is
// PERIOD ns.
//
// Educational Notes:
//     - Verilog thinks in terms of a whole bunch of tasks that could
//       even be happening simultaneously.  
//     - An initial block provides a task that begins right at the
//       start of the simulation (at time = 0).
//     - An always block that has no conditions on it will always 
//       happen.  At the beginning it will happen; then, when it 
//       finishes, it will begin again.
///////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module clock(output reg clk);
    parameter PERIOD = 200;      // The period of the clock.  Set as needed
    parameter HALFPERIOD = PERIOD/2;

    always begin                 // Always be doing this.  
        #HALFPERIOD              // Every 50 time units, flip the clock
        clk = ~clk;  
    end 

    initial begin                // at the beginning of the simulation, 
        clk = 0;                 // set the clock to be 0.
    end
endmodule
