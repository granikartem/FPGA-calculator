`timescale 1ns/1ps

module tb_calculator_top;

  logic clk;
  logic [15:0] SW;
  logic [4:0]  buttons;
  wire  [15:0] LED;

  calculator_top dut (
    .clk(clk),
    .SW(SW),
    .buttons(buttons),
    .LED(LED)
  );

  initial clk = 0;
  always #10 clk = ~clk;

  initial begin
    SW      = 16'h0000;
    buttons = 5'b00000;
  end

endmodule
