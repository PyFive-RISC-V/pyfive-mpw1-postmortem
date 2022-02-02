/*
 * top.v
 *
 * Top level for the initial bring up bitstream
 *
 * vim: ts=4 sw=4
 *
 * Copyright (C) 2021-2022  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module top (
	// DUT
		// Flash
	input  wire       dut_spi_cs_n,
	input  wire       dut_spi_clk,
	input  wire       dut_spi_mosi,
	output wire       dut_spi_miso,

		// Clock / Reset
	inout  wire       dut_gpio,
	output reg        dut_xclk,
	output reg        dut_rst_n,

		// Power control
	output wire       dut_vdd,
	output wire       dut_vdd1,
	output wire       dut_vdd2,

		// Misc pins
	inout  wire [5:0] dut_usr,
	inout  wire [7:0] pmod,

	// UART
	input  wire uart_rx,
	output wire uart_tx,

	// Clock
	input  wire clk_in
);

	// Config
	// ------

	localparam integer WB_N = 4;

	genvar i;


	// Signals
	// -------

	// Control
	wire [31:0] aux_csr;

	// Wishbone interface
	reg  [31:0]     wb_wdata;
	reg  [31:0]     wb_rdata[0:WB_N-1];
	reg  [15:0]     wb_addr;
	reg             wb_we;
	reg  [WB_N-1:0] wb_cyc;
	wire [WB_N-1:0] wb_ack;
	wire [(WB_N*32)-1:0] wb_rdata_flat;

	// Clock / Reset
	wire       rst;
	wire       clk;


	// Host interface
	// --------------

	uart2wb #(
		.UART_DIV(25), // 2 Mbaud
		.WB_N(WB_N)
	) if_I (
		.uart_rx  (uart_rx),
		.uart_tx  (uart_tx),
		.wb_wdata (wb_wdata),
		.wb_rdata (wb_rdata_flat),
		.wb_addr  (wb_addr),
		.wb_we    (wb_we),
		.wb_cyc   (wb_cyc),
		.wb_ack   (wb_ack),
		.aux_csr  (aux_csr),
		.clk      (clk),
		.rst      (rst)
	);

	for (i=0; i<WB_N; i=i+1)
		assign wb_rdata_flat[i*32+:32] = wb_rdata[i];


	// Global control
	// --------------

	dutif_ctrl ctrl_I (
		.dut_gpio  (dut_gpio),
		.dut_xclk  (dut_xclk),
		.dut_rst_n (dut_rst_n),
		.dut_vdd   (dut_vdd),
		.dut_vdd1  (dut_vdd1),
		.dut_vdd2  (dut_vdd2),
		.wb_addr   (wb_addr[3:0]),
		.wb_rdata  (wb_rdata[0]),
		.wb_wdata  (wb_wdata),
		.wb_we     (wb_we),
		.wb_cyc    (wb_cyc[0]),
		.wb_ack    (wb_ack[0]),
		.clk       (clk),
		.rst       (rst)
	);


	// Flash emulation
	// ---------------

	dutif_flash flash_I (
		.dut_spi_cs_n (dut_spi_cs_n),
		.dut_spi_clk  (dut_spi_clk),
		.dut_spi_mosi (dut_spi_mosi),
		.dut_spi_miso (dut_spi_miso),
		.dut_rst_n    (dut_rst_n),
		.wb_addr      (wb_addr),
		.wb_rdata     (wb_rdata[1]),
		.wb_wdata     (wb_wdata),
		.wb_we        (wb_we),
		.wb_cyc       (wb_cyc[1]),
		.wb_ack       (wb_ack[1]),
		.clk          (clk),
		.rst          (rst)
	);


	// User IO
	// -------

	// Video Clock (1:2 clk)
	reg vid_clk;

	always @(posedge clk)
		vid_clk <= ~vid_clk;

	SB_IO #(
		.PIN_TYPE    (6'b0100_11),
		.PULLUP      (1'b0),
		.NEG_TRIGGER (1'b0),
		.IO_STANDARD ("SB_LVCMOS")
	) iob_hdmi_clk_I (
		.PACKAGE_PIN (dut_usr[0]),
		.OUTPUT_CLK  (clk),
		.D_OUT_0     (vid_clk),
		.D_OUT_1     (vid_clk ^ aux_csr[0])
	);

	// Test UART
	uart_wb #(
		.DIV_WIDTH(15),
		.DW(32)
	) test_uart_I (
		.uart_tx  (dut_usr[1]),
		.uart_rx  (dut_usr[2]),
		.wb_addr  (wb_addr[1:0]),
		.wb_rdata (wb_rdata[2]),
		.wb_wdata (wb_wdata),
		.wb_we    (wb_we),
		.wb_cyc   (wb_cyc[2]),
		.wb_ack   (wb_ack[2]),
		.clk      (clk),
		.rst      (rst)
	);

	// IO mapper hardware
	io_mapper io_mapper_I (
		.drv_weak   (dut_usr[4]),
		.drv_strong (dut_usr[5]),
		.sense      (pmod),
		.wb_addr    (wb_addr[3:0]),
		.wb_rdata   (wb_rdata[3]),
		.wb_wdata   (wb_wdata),
		.wb_we      (wb_we),
		.wb_cyc     (wb_cyc[3]),
		.wb_ack     (wb_ack[3]),
		.clk        (clk),
		.rst        (rst)
	);


	// CRG
	// ---

	sysmgr crg_I (
		.clk_in  (clk_in),
		.rst_in  (1'b0),
		.clk_out (clk),
		.rst_out (rst)
	);

endmodule
