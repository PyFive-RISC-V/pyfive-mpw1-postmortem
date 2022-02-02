/*
 * flashemu_tb.v
 *
 * Test bench for flash emulation
 *
 * vim: ts=4 sw=4
 *
 * Copyright (C) 2021-2022  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */


`default_nettype none
`timescale 1 ns / 100 ps

module flashemu_tb;

	// Signals
	// -------

	reg         valid;
	wire        ready;
	reg  [23:0] addr;
	wire [31:0] rdata;

	wire       flash_csb;
	wire       flash_clk;
	wire [3:0] flash_io_oe;
	wire [3:0] flash_io_do;
	wire [3:0] flash_io_di;

	wire  [3:0] cfgreg_we;
	wire [31:0] cfgreg_di;
	wire [31:0] cfgreg_do;

	reg clk_slow = 1'b0;
	reg clk_fast = 1'b0;
	reg rst = 1'b1;


	// Setup recording
	// ---------------

	initial begin
		$dumpfile("flashemu_tb.vcd");
		$dumpvars(0,flashemu_tb);
		# 2000000 $finish;
	end

	always #10  clk_slow <= !clk_slow;
	always #2.5 clk_fast <= !clk_fast;

	initial begin
		#200 rst = 0;
	end


	// DUT
	// ---

	spimemio dut_I (
		.clk          (clk_slow),
		.resetn       (~rst),
		.valid        (valid),
		.ready        (ready),
		.addr         (addr),
		.rdata        (rdata),
		.flash_csb    (flash_csb),
		.flash_clk    (flash_clk),
		.flash_io0_oe (flash_io_oe[0]),
		.flash_io1_oe (flash_io_oe[1]),
		.flash_io2_oe (flash_io_oe[2]),
		.flash_io3_oe (flash_io_oe[3]),
		.flash_io0_do (flash_io_do[0]),
		.flash_io1_do (flash_io_do[1]),
		.flash_io2_do (flash_io_do[2]),
		.flash_io3_do (flash_io_do[3]),
		.flash_io0_di (flash_io_di[0]),
		.flash_io1_di (flash_io_di[1]),
		.flash_io2_di (flash_io_di[2]),
		.flash_io3_di (flash_io_di[3]),
		.cfgreg_we    (cfgreg_we),
		.cfgreg_di    (cfgreg_di),
		.cfgreg_do    (cfgreg_do)
	);

	flashemu flash_I (
		.spi_mosi (flash_io_do[0]),
		.spi_miso (flash_io_di[1]),
		.spi_cs_n (flash_csb),
		.spi_clk  (flash_clk),
		.clk      (clk_fast),
		.rst      (rst)
	);

	// Address
	always @(posedge clk_slow)
		if (rst) begin
			valid <= 1'b0;
			addr  <= 32'h00000000;
		end else begin
			if (addr == 32'h00000000)
				valid <= 1'b1;

			if (valid & ready)
				addr <= addr + 4;

			if ((addr == 32'h00000000) & valid & ready)
				valid <= 1'b0;
		end

	// No writes
	assign cfgreg_di = 32'h00000000;
	assign cfgreg_we = 4'h0;

endmodule // flashemu_tb
