`timescale 1ns/10ps
module calculator_mealy
  #
  (
   parameter BITS = 32
   )
  (
   input wire                    clk,
   input wire                    start,
   input wire [4:0]              buttons,
   input wire signed [15:0]      switch,

   output logic                  done,
   output logic signed [BITS-1:0] accum
   );

  import calculator_pkg::*;

  typedef enum bit {
    IDLE,
    READY
  } state_t;

  state_t               state;
  logic signed [BITS-1:0] accumulator;

  initial begin
    state       = IDLE;
    accumulator = '0;
    done        = '0;
  end

  always @(posedge clk) begin
    done <= '0;
    case (state)

      // Ждем первого нажатия: любая кнопка кроме DOWN просто загружает SW в ACC
      IDLE: begin
        if (start) begin
          if (buttons[DOWN]) begin
            accumulator <= '0;
          end else begin
            accumulator <= BITS'(signed'(switch));
            state       <= READY;
          end
        end
      end

      // Каждое нажатие сразу выполняет текущую операцию над ACC и SW
      READY: begin
        if (start) begin
          done <= '1;
          case (1'b1)
            buttons[DOWN]:  begin
              accumulator <= '0;
              state       <= IDLE;
            end
            buttons[LEFT]:  accumulator <= accumulator + BITS'(signed'(switch));
            buttons[RIGHT]: accumulator <= accumulator - BITS'(signed'(switch));
            buttons[UP]:    accumulator <= accumulator * BITS'(signed'(switch));
            default:        accumulator <= accumulator; // CENTER или несколько кнопок
          endcase
        end
      end

    endcase
  end

  assign accum = accumulator;

endmodule
