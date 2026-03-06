`timescale 1ns/10ps
module calculator_moore
  #
  (
   parameter BITS = 32
   )
  (
   input wire               clk,
   input wire               start,
   input wire [4:0]         buttons,
   input wire signed [15:0] switch,

   output logic             done,
   output logic [BITS-1:0]  accum
   );

  import calculator_pkg::*;

  localparam BC = $clog2(BITS);

  logic [4:0]       op_store;
  logic [4:0]       last_op;
  logic [BITS-1:0]  accumulator;

  typedef enum bit [2:0]
               {
                IDLE,
                WAIT4BUTTON,
                ADD,
                SUB,
                MULT
                } state_t;

  state_t state;

  initial begin
    state       = IDLE;
    accumulator = '0;
    last_op     = '0;
    op_store    = '0;
  end

  always @(posedge clk) begin
    done <= '0;
    case (state)
      IDLE: begin
        accumulator <= '0;
        last_op     <= buttons;
        accumulator <= switch;
        if (start) state <= buttons[DOWN] ? IDLE : WAIT4BUTTON;
      end
      WAIT4BUTTON: begin
        op_store <= buttons;
        if (start) begin
          case (1'b1)
            last_op[UP]:     state <= MULT;
            last_op[DOWN]:   state <= IDLE;
            last_op[LEFT]:   state <= ADD;
            last_op[RIGHT]:  state <= SUB;
            default:         state <= WAIT4BUTTON;
          endcase
        end else state <= WAIT4BUTTON;
      end
      MULT: begin
        last_op     <= op_store;
        accumulator <= accumulator * switch;
        state       <= WAIT4BUTTON;
      end
      ADD: begin
        last_op     <= op_store;
        accumulator <= accumulator + switch;
        state       <= WAIT4BUTTON;
      end
      SUB: begin
        last_op     <= op_store;
        accumulator <= accumulator - switch;
        state       <= WAIT4BUTTON;
      end
    endcase
  end

  assign accum = accumulator;

endmodule
