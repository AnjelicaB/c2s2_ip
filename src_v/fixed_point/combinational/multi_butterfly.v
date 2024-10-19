`default_nettype none
`default_nettype none
`default_nettype none
module fixed_point_combinational_Multiplier (
	a,
	b,
	c
);
	parameter signed [31:0] n = 32;
	parameter signed [31:0] d = 16;
	parameter [0:0] sign = 1;
	input wire [n - 1:0] a;
	input wire [n - 1:0] b;
	output wire [n - 1:0] c;
	wire [(d + n) - 1:0] prod;
	wire [(d + n) - 1:0] a_ext;
	wire [(d + n) - 1:0] b_ext;
	generate
		if (sign) begin : genblk1
			assign a_ext = {{d {a[n - 1]}}, a};
			assign b_ext = {{d {b[n - 1]}}, b};
			assign prod = a_ext * b_ext;
		end
		else begin : genblk1
			assign prod = a * b;
		end
	endgenerate
	assign c = prod[(n + d) - 1:d];
	generate
		if (d > 0) begin : genblk2
			wire unused;
			assign unused = &{1'b0, prod[d - 1:0], 1'b0};
		end
	endgenerate
endmodule
module fixed_point_combinational_ComplexMultiplierS (
	ar,
	ac,
	br,
	bc,
	cr,
	cc
);
	parameter signed [31:0] n = 32;
	parameter signed [31:0] d = 16;
	input wire [n - 1:0] ar;
	input wire [n - 1:0] ac;
	input wire [n - 1:0] br;
	input wire [n - 1:0] bc;
	output wire [n - 1:0] cr;
	output wire [n - 1:0] cc;
	wire [n - 1:0] c_ar;
	wire [n - 1:0] c_ac;
	wire [n - 1:0] c_br;
	wire [n - 1:0] c_bc;
	wire [n - 1:0] arXbr;
	wire [n - 1:0] acXbc;
	wire [n - 1:0] arcXbrc;
	assign c_ar = ar;
	assign c_ac = ac;
	assign c_br = br;
	assign c_bc = bc;
	fixed_point_combinational_Multiplier #(
		.n(n),
		.d(d),
		.sign(1)
	) arXbrMult(
		.a(c_ar),
		.b(c_br),
		.c(arXbr)
	);
	fixed_point_combinational_Multiplier #(
		.n(n),
		.d(d),
		.sign(1)
	) acXbcMult(
		.a(c_ac),
		.b(c_bc),
		.c(acXbc)
	);
	fixed_point_combinational_Multiplier #(
		.n(n),
		.d(d),
		.sign(1)
	) arXbrcMult(
		.a(c_ar + c_ac),
		.b(c_br + c_bc),
		.c(arcXbrc)
	);
	assign cr = arXbr - acXbc;
	assign cc = (arcXbrc - arXbr) - acXbc;
endmodule
module fixed_point_combinational_ComplexMultiplier (
	clk,
	reset,
	recv_val,
	recv_rdy,
	send_val,
	send_rdy,
	ar,
	ac,
	br,
	bc,
	cr,
	cc
);
	parameter signed [31:0] n = 32;
	parameter signed [31:0] d = 16;
	parameter signed [31:0] num_mults = 1;
	input wire clk;
	input wire reset;
	input wire recv_val;
	output reg recv_rdy;
	output reg send_val;
	input wire send_rdy;
	input wire [n - 1:0] ar;
	input wire [n - 1:0] ac;
	input wire [n - 1:0] br;
	input wire [n - 1:0] bc;
	output wire [n - 1:0] cr;
	output wire [n - 1:0] cc;
	reg [n - 1:0] c_ar;
	reg [n - 1:0] c_ac;
	reg [n - 1:0] c_br;
	reg [n - 1:0] c_bc;
	reg [n - 1:0] arXbr;
	reg [n - 1:0] acXbc;
	reg [n - 1:0] arcXbrc;
	generate
		if (num_mults == 3) begin : genblk1
			wire [n:1] sv2v_tmp_1272E;
			assign sv2v_tmp_1272E = ar;
			always @(*) c_ar = sv2v_tmp_1272E;
			wire [n:1] sv2v_tmp_AE874;
			assign sv2v_tmp_AE874 = ac;
			always @(*) c_ac = sv2v_tmp_AE874;
			wire [n:1] sv2v_tmp_29444;
			assign sv2v_tmp_29444 = br;
			always @(*) c_br = sv2v_tmp_29444;
			wire [n:1] sv2v_tmp_F85B2;
			assign sv2v_tmp_F85B2 = bc;
			always @(*) c_bc = sv2v_tmp_F85B2;
			wire [n:1] sv2v_tmp_arXbrMult_c;
			always @(*) arXbr = sv2v_tmp_arXbrMult_c;
			fixed_point_combinational_Multiplier #(
				.n(n),
				.d(d),
				.sign(1)
			) arXbrMult(
				.a(c_ar),
				.b(c_br),
				.c(sv2v_tmp_arXbrMult_c)
			);
			wire [n:1] sv2v_tmp_acXbcMult_c;
			always @(*) acXbc = sv2v_tmp_acXbcMult_c;
			fixed_point_combinational_Multiplier #(
				.n(n),
				.d(d),
				.sign(1)
			) acXbcMult(
				.a(c_ac),
				.b(c_bc),
				.c(sv2v_tmp_acXbcMult_c)
			);
			wire [n:1] sv2v_tmp_arXbrcMult_c;
			always @(*) arcXbrc = sv2v_tmp_arXbrcMult_c;
			fixed_point_combinational_Multiplier #(
				.n(n),
				.d(d),
				.sign(1)
			) arXbrcMult(
				.a(c_ar + c_ac),
				.b(c_br + c_bc),
				.c(sv2v_tmp_arXbrcMult_c)
			);
			assign cr = arXbr - acXbc;
			assign cc = (arcXbrc - arXbr) - acXbc;
			wire [1:1] sv2v_tmp_1010E;
			assign sv2v_tmp_1010E = send_rdy;
			always @(*) recv_rdy = sv2v_tmp_1010E;
			wire [1:1] sv2v_tmp_3CA7E;
			assign sv2v_tmp_3CA7E = recv_val;
			always @(*) send_val = sv2v_tmp_3CA7E;
			reg unused = &{clk, reset};
		end
		else if (num_mults == 1) begin : genblk1
			reg [2:0] IDLE = 3'd0;
			reg [2:0] MUL1 = 3'd1;
			reg [2:0] MUL2 = 3'd2;
			reg [2:0] MUL3 = 3'd3;
			reg [2:0] DONE = 3'd4;
			reg [2:0] state;
			reg [2:0] next_state;
			reg [n - 1:0] mul_a;
			reg [n - 1:0] mul_b;
			wire [n - 1:0] mul_c;
			reg unused = &{IDLE, MUL1, MUL2, MUL3, DONE};
			always @(posedge clk)
				if (reset) begin
					state <= IDLE;
					c_ar <= 0;
					c_ac <= 0;
					c_br <= 0;
					c_bc <= 0;
					arXbr <= 0;
					acXbc <= 0;
					arcXbrc <= 0;
				end
				else begin
					state <= next_state;
					if ((state == IDLE) && recv_val) begin
						c_ar <= ar;
						c_ac <= ac;
						c_br <= br;
						c_bc <= bc;
						arXbr <= 0;
						acXbc <= 0;
						arcXbrc <= 0;
					end
					else if (state == MUL1)
						arXbr <= mul_c;
					else if (state == MUL2)
						acXbc <= mul_c;
					else if (state == MUL3)
						arcXbrc <= mul_c;
				end
			always @(*) begin
				next_state = state;
				recv_rdy = 0;
				send_val = 0;
				mul_a = 0;
				mul_b = 0;
				case (state)
					IDLE: begin
						recv_rdy = 1;
						if (recv_val)
							next_state = MUL1;
						else
							next_state = IDLE;
					end
					MUL1: begin
						next_state = MUL2;
						mul_a = c_ar;
						mul_b = c_br;
					end
					MUL2: begin
						next_state = MUL3;
						mul_a = c_ac;
						mul_b = c_bc;
					end
					MUL3: begin
						next_state = DONE;
						mul_a = c_ar + c_ac;
						mul_b = c_br + c_bc;
					end
					DONE: begin
						send_val = 1;
						if (send_rdy)
							next_state = IDLE;
						else
							next_state = state;
					end
					default:
						;
				endcase
			end
			fixed_point_combinational_Multiplier #(
				.n(n),
				.d(d),
				.sign(1)
			) arXbrMult(
				.a(mul_a),
				.b(mul_b),
				.c(mul_c)
			);
			assign cr = arXbr - acXbc;
			assign cc = (arcXbrc - arXbr) - acXbc;
		end
	endgenerate
endmodule
module fixed_point_combinational_MultiButterfly (
	clk,
	reset,
	recv_val,
	recv_rdy,
	send_val,
	send_rdy,
	ar,
	ac,
	br,
	bc,
	wr,
	wc,
	cr,
	cc,
	dr,
	dc
);
	parameter signed [31:0] n = 32;
	parameter signed [31:0] d = 16;
	parameter signed [31:0] b = 4;
	input wire clk;
	input wire reset;
	input wire recv_val;
	output wire recv_rdy;
	output wire send_val;
	input wire send_rdy;
	input wire [(b * n) - 1:0] ar;
	input wire [(b * n) - 1:0] ac;
	input wire [(b * n) - 1:0] br;
	input wire [(b * n) - 1:0] bc;
	input wire [(b * n) - 1:0] wr;
	input wire [(b * n) - 1:0] wc;
	output wire [(b * n) - 1:0] cr;
	output wire [(b * n) - 1:0] cc;
	output wire [(b * n) - 1:0] dr;
	output wire [(b * n) - 1:0] dc;
	localparam signed [31:0] bb = b - 1;
	reg [n - 1:0] s_ar [0:b - 1];
	reg [n - 1:0] s_ac [0:b - 1];
	reg [n - 1:0] s_br [0:b - 1];
	reg [n - 1:0] s_bc [0:b - 1];
	reg [n - 1:0] s_cr [0:b - 1];
	reg [n - 1:0] s_cc [0:b - 1];
	reg [n - 1:0] s_dr [0:b - 1];
	reg [n - 1:0] s_dc [0:b - 1];
	reg [n - 1:0] s_wr [0:b - 1];
	reg [n - 1:0] s_wc [0:b - 1];
	reg [2:0] IDLE = 3'd0;
	reg [2:0] COMP = 3'd1;
	reg [2:0] DONE = 3'd2;
	reg [2:0] state;
	reg [2:0] next_state;
	reg [(b == 1 ? 0 : $clog2(b) - 1):0] comp_state;
	reg [(b == 1 ? 0 : $clog2(b) - 1):0] next_comp_state;
	reg [n - 1:0] m_ar;
	reg [n - 1:0] m_ac;
	reg [n - 1:0] m_br;
	reg [n - 1:0] m_bc;
	wire [n - 1:0] m_cr;
	wire [n - 1:0] m_cc;
	wire mult_recv_rdy;
	wire mult_send_val;
	reg unused = &{IDLE, COMP, DONE, mult_recv_rdy, mult_send_val};
	fixed_point_combinational_ComplexMultiplier #(
		.n(n),
		.d(d),
		.num_mults(3)
	) mult(
		.recv_val(1'b1),
		.recv_rdy(mult_recv_rdy),
		.send_val(mult_send_val),
		.send_rdy(1'b1),
		.clk(clk),
		.reset(reset),
		.ar(m_ar),
		.ac(m_ac),
		.br(m_br),
		.bc(m_bc),
		.cr(m_cr),
		.cc(m_cc)
	);
	assign recv_rdy = state == IDLE;
	assign send_val = state == DONE;
	genvar i;
	generate
		for (i = 0; i < b; i = i + 1) begin : g_loop
			always @(posedge clk)
				if (reset) begin
					s_ac[i] <= 0;
					s_ar[i] <= 0;
					s_bc[i] <= 0;
					s_br[i] <= 0;
					s_cr[i] <= 0;
					s_cc[i] <= 0;
					s_wr[i] <= 0;
					s_wc[i] <= 0;
				end
				else if (recv_rdy && recv_val) begin
					s_ar[i] <= ar[((b - 1) - i) * n+:n];
					s_ac[i] <= ac[((b - 1) - i) * n+:n];
					s_br[i] <= br[((b - 1) - i) * n+:n];
					s_bc[i] <= bc[((b - 1) - i) * n+:n];
					s_wr[i] <= wr[((b - 1) - i) * n+:n];
					s_wc[i] <= wc[((b - 1) - i) * n+:n];
					s_cc[i] <= 0;
					s_cr[i] <= 0;
				end
			assign cr[((b - 1) - i) * n+:n] = s_cr[i];
			assign cc[((b - 1) - i) * n+:n] = s_cc[i];
			assign dr[((b - 1) - i) * n+:n] = s_dr[i];
			assign dc[((b - 1) - i) * n+:n] = s_dc[i];
		end
	endgenerate
	always @(posedge clk) begin
		state <= next_state;
		comp_state <= next_comp_state;
		if (state == COMP) begin
			s_cr[comp_state] <= s_ar[comp_state] + m_cr;
			s_cc[comp_state] <= s_ac[comp_state] + m_cc;
			s_dr[comp_state] <= s_ar[comp_state] - m_cr;
			s_dc[comp_state] <= s_ac[comp_state] - m_cc;
		end
	end
	always @(*) begin
		next_state = state;
		next_comp_state = 0;
		if (reset) begin
			next_state = IDLE;
			next_comp_state = 0;
		end
		else if ((state == IDLE) && recv_rdy) begin
			if (recv_val)
				next_state = COMP;
		end
		else if ((state == DONE) && send_val) begin
			if (send_rdy)
				next_state = IDLE;
		end
		else if (state == COMP)
			if (comp_state == bb[(b == 1 ? 0 : $clog2(b) - 1):0]) begin
				next_state = DONE;
				next_comp_state = 0;
			end
			else
				next_comp_state = comp_state + 1;
		m_ac = s_bc[comp_state];
		m_ar = s_br[comp_state];
		m_bc = s_wc[comp_state];
		m_br = s_wr[comp_state];
	end
endmodule
