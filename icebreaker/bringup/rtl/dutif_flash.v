/*
 * dutif_flash.v
 *
 * Handle flash interface of the DUT
 *
 * vim: ts=4 sw=4
 *
 * Copyright (C) 2021-2022  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module dutif_flash (
	// DUT Flash
	input  wire        dut_spi_cs_n,
	input  wire        dut_spi_clk,
	input  wire        dut_spi_mosi,
	output wire        dut_spi_miso,

	// Aux
	input  wire        dut_rst_n,

	// Bus interface
	input  wire [15:0] wb_addr,
	output reg  [31:0] wb_rdata,
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

	// Bus
	wire        bus_rd_clr;

	// Mem write
	wire [31:0] mem_wr_data;
	wire [15:0] mem_wr_addr;
	reg         mem_wr_ena;

	// Monitor port
	wire  [7:0] mon_cmd;
	wire        mon_stb;

	reg  [31:0] cmd_cnt;


	// Bus Interface
	// -------------

	// Ack
	always @(posedge clk)
		wb_ack <= wb_cyc & ~wb_ack;

	// Memory write port
	assign mem_wr_data = wb_wdata;
	assign mem_wr_addr = wb_addr;

	always @(posedge clk)
		mem_wr_ena <= wb_cyc & ~wb_ack & wb_we;

	// Read
	always @(posedge clk)
		if (bus_rd_clr)
			wb_rdata <= 32'h00000000;
		else
			wb_rdata <= cmd_cnt;

	assign bus_rd_clr = ~wb_cyc | wb_ack;


	// Emulator
	// --------

	// Instance
	flashemu flash_I (
		.spi_mosi    (dut_spi_mosi),
		.spi_miso    (dut_spi_miso),
		.spi_cs_n    (dut_spi_cs_n),
		.spi_clk     (dut_spi_clk),
		.mem_wr_data (mem_wr_data),
		.mem_wr_addr (mem_wr_addr),
		.mem_wr_ena  (mem_wr_ena),
		.mon_cmd     (mon_cmd),
		.mon_stb     (mon_stb),
		.clk         (clk),
		.rst         (rst)
	);

	// Count commands
	always @(posedge clk)
		if (dut_rst_n == 1'b0)
			cmd_cnt <= 32'h00000000;
		else
			cmd_cnt <= cmd_cnt + mon_stb;

endmodule // dutif_flash
