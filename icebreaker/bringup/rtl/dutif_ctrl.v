/*
 * dutif_ctrl.v
 *
 * Handle global control of DUT
 *
 * vim: ts=4 sw=4
 *
 * Copyright (C) 2021-2022  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module dutif_ctrl (
	// DUT
		// Clock / Reset
	inout  wire       dut_gpio,
	output reg        dut_xclk,
	output reg        dut_rst_n,

		// Power control
	output wire       dut_vdd,
	output wire       dut_vdd1,
	output wire       dut_vdd2,

	// Bus interface
	input  wire  [3:0] wb_addr,
	output wire [31:0] wb_rdata,
	input  wire [31:0] wb_wdata,
	input  wire        wb_we,
	input  wire        wb_cyc,
	output reg         wb_ack,

	// Clock / Reset
	input  wire clk,
	input  wire rst
);

	// Signals
	// -------

	wire       bus_we_rst;
	reg        bus_we_ctrl_crg;
	reg        bus_we_ctrl_vdd;

	reg  [1:0] ctrl_rst_mode;

	reg  [9:0] ctrl_vdd;
	reg  [9:0] ctrl_vdd1;
	reg  [9:0] ctrl_vdd2;

	reg  [3:0] seq_inc;
	reg [27:0] seq_cnt;
	reg  [3:0] seq_rst_msk_hi;
	reg  [3:0] seq_rst_msk_lo;


	// Bus interface
	// -------------

	// Ack
	always @(posedge clk)
		wb_ack <= wb_cyc & ~wb_ack;

	// Don't support read at all
	assign wb_rdata = 32'h00000000;

	// Write enables
	assign bus_we_rst = rst | wb_ack | ~wb_cyc | ~wb_we;

	always @(posedge clk)
		if (bus_we_rst) begin
			bus_we_ctrl_crg <= 1'b0;
			bus_we_ctrl_vdd <= 1'b0;
		end else begin
			bus_we_ctrl_crg <= (wb_addr == 4'h0);
			bus_we_ctrl_vdd <= (wb_addr == 4'h1);
		end

	// CRG control
	always @(posedge clk or posedge rst)
		if (rst) begin
			ctrl_rst_mode   <= 2'b00;
			seq_rst_msk_hi  <= 4'b0000;
			seq_rst_msk_lo  <= 4'b1100;
			seq_inc         <= 4'b0010;
		end else if (bus_we_ctrl_crg) begin
			ctrl_rst_mode   <= wb_wdata[3:2];
			seq_rst_msk_hi  <= (4'b1111 >> wb_wdata[7:6]);
			seq_rst_msk_lo  <= (4'b1111 << wb_wdata[5:4]);
			seq_inc         <= (4'b1000 >> wb_wdata[1:0]);
		end

	// VDD control
	always @(posedge clk or posedge rst)
		if (rst) begin
			ctrl_vdd  <= 10'd0;
			ctrl_vdd1 <= 10'd0;
			ctrl_vdd2 <= 10'd0;
		end else if (bus_we_ctrl_vdd) begin
			ctrl_vdd  <= wb_wdata[29:20];
			ctrl_vdd1 <= wb_wdata[19:10];
			ctrl_vdd2 <= wb_wdata[ 9: 0];
		end


	// DUT clock and reset
	// -------------------

	always @(posedge clk)
		if (rst)
			seq_cnt <= 0;
		else
			seq_cnt <= seq_cnt + seq_inc;

	always @(posedge clk)
	begin
		// Reset
		if (ctrl_rst_mode[1] == 1'b1)
			dut_rst_n <= |(seq_cnt[27:8] & {seq_rst_msk_hi, 12'hfff, seq_rst_msk_lo});
		else
			dut_rst_n <= ctrl_rst_mode[0];

		// Clock
		dut_xclk <= seq_cnt[3];
	end


	// VDD control
	// -----------

	pdm #(
		.WIDTH  (10),
		.DITHER ("NO"),
		.PHY    ("ICE40")
	) pdm_dut_vdd_I (
		.pdm     (dut_vdd),
		.cfg_val (ctrl_vdd),
		.cfg_oe  (1'b1),
		.clk     (clk),
		.rst     (rst)
	);

	pdm #(
		.WIDTH  (10),
		.DITHER ("NO"),
		.PHY    ("ICE40")
	) pdm_dut_vdd1_I (
		.pdm     (dut_vdd1),
		.cfg_val (ctrl_vdd1),
		.cfg_oe  (1'b1),
		.clk     (clk),
		.rst     (rst)
	);

	pdm #(
		.WIDTH  (10),
		.DITHER ("NO"),
		.PHY    ("ICE40")
	) pdm_dut_vdd2_I (
		.pdm     (dut_vdd2),
		.cfg_val (ctrl_vdd2),
		.cfg_oe  (1'b1),
		.clk     (clk),
		.rst     (rst)
	);

endmodule // dutif_ctrl
