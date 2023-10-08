`include "src/fft/cooley_tukey/helpers/crossbar.v"

module CrossbarTestHarness #(
  BIT_WIDTH = 1,
  SIZE_FFT  = 2,
  STAGE_FFT = 0,
  FRONT     = 1
) (
  input  logic [BIT_WIDTH * SIZE_FFT * 2 - 1:0] recv_msg,
  input  logic                                  recv_val,
  output logic                                  recv_rdy,

  output logic [BIT_WIDTH * SIZE_FFT * 2 - 1:0] send_msg,
  input  logic                                  send_rdy,
  output logic                                  send_val
);

  logic [BIT_WIDTH - 1:0] crossbar_in   [SIZE_FFT * 2 - 1:0];
  logic [BIT_WIDTH - 1:0] crossbar_out  [SIZE_FFT * 2 - 1:0];

  logic recv_val_wide [SIZE_FFT - 1:0];
  logic recv_rdy_wide [SIZE_FFT - 1:0];

  logic send_rdy_wide [SIZE_FFT - 1:0];
  logic send_val_wide [SIZE_FFT - 1:0];

  generate
    for (genvar i = 0; i < SIZE_FFT * 2; i = i + 1) begin
      assign crossbar_in[i][BIT_WIDTH-1:0]    = recv_msg[BIT_WIDTH*i+:BIT_WIDTH];
      assign send_msg[BIT_WIDTH*i+:BIT_WIDTH] = crossbar_out[i][BIT_WIDTH-1:0];
    end
    for (genvar i = 0; i < SIZE_FFT; i = i + 1) begin
      assign recv_val_wide[i] = recv_val;
      assign send_rdy_wide[i] = send_rdy;

      assign recv_rdy = recv_rdy || recv_rdy_wide[i];
      assign send_val = send_val || send_val_wide[i];
    end
  endgenerate

  FFTCrossbar #(
    .BIT_WIDTH(BIT_WIDTH),
    .SIZE_FFT (SIZE_FFT),
    .STAGE_FFT(STAGE_FFT)
  ) crossbar (
    .recv_real(crossbar_in[SIZE_FFT*2-1:SIZE_FFT]),
    .recv_imaginary(crossbar_in[SIZE_FFT-1:0]),
    .recv_val(recv_val_wide),
    .recv_rdy(recv_rdy_wide),
    .send_real(crossbar_out[SIZE_FFT*2-1:SIZE_FFT]),
    .send_imaginary(crossbar_out[SIZE_FFT-1:0]),
    .send_val(send_val_wide),
    .send_rdy(send_rdy_wide)
  );

endmodule
