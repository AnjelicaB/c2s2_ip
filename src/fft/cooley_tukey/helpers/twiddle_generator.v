`ifndef TWIDDLE_GENERATOR
`define TWIDDLE_GENERATOR

/// Twiddle Generator module for a stage in a cooley tukey FFT
module TwiddleGenerator #(
  parameter int BIT_WIDTH  = 4,
  parameter int DECIMAL_PT = 2,
  parameter int SIZE_FFT   = 8,
  parameter int STAGE_FFT  = 0
) (
  input logic [BIT_WIDTH - 1:0] sine_wave_in[0:SIZE_FFT - 1],  //sine_wave_in = sin(2*pi m / N)

  output logic [BIT_WIDTH - 1:0] twiddle_real     [SIZE_FFT/2 - 1:0],
  output logic [BIT_WIDTH - 1:0] twiddle_imaginary[SIZE_FFT/2 - 1:0]
);

  generate
    for (genvar m = 0; m < 2 ** STAGE_FFT; m = m + 1) begin
      for (genvar i = 0; i < SIZE_FFT; i = i + 2 ** (STAGE_FFT + 1)) begin
        // the index of the sine wave to use.
        int idx = m * SIZE_FFT / (1 << (STAGE_FFT + 1));

        assign twiddle_real[i/2+m] = sine_wave_in[(idx+SIZE_FFT/4)%SIZE_FFT];
        assign twiddle_imaginary[i/2+m] = -sine_wave_in[idx%SIZE_FFT];
      end
    end
  endgenerate

endmodule

`endif
