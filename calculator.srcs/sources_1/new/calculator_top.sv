`timescale 1ns/10ps
module calculator_top
  #
  (
   parameter BITS = 32
   )
  (
   input wire        clk,
   input wire [15:0] SW,
   input wire [4:0]  buttons,
   output logic [15:0] LED
   );

  import calculator_pkg::*;

  logic [31:0] accumulator;
  logic [2:0] button_sync;
  logic       counter_en;
  logic [7:0] counter;
  logic       button_down;
  logic [4:0] button_capt;
  logic [15:0] sw_capt;

  initial begin
    button_sync = '0;
    counter_en  = '0;
    counter     = '0;
    button_down = '0;
    button_capt = '0;
    sw_capt     = '0;
    LED         = '0;
  end

  always @(posedge clk) begin
    button_down <= '0;
    button_capt <= '0;
    button_sync <= button_sync << 1 | (|buttons);
    if (button_sync[2:1] == 2'b01) counter_en <= '1;
    else if (~button_sync[1])      counter_en <= '0;

    if (counter_en) begin
      counter <= counter + 1'b1;
      if (&counter) begin
        counter_en  <= '0;
        counter     <= '0;
        button_down <= '1;
        button_capt <= buttons;
        sw_capt     <= SW;
      end
    end
  end

  calculator_mealy
    #
    (
     .BITS(BITS)
     )
  u_sm
    (
     .clk(clk),
     .start(button_down),
     .buttons(button_capt),
     .switch(sw_capt),

     .done(),
     .accum(accumulator)
     );

  always @(posedge clk) begin
    LED <= accumulator[15:0];
  end

endmodule
