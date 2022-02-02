/*
 * io_ampper.v
 *
 * Special hardware block to aid in IO mapping
 *
 * vim: ts=4 sw=4
 *
 * Copyright (C) 2021-2022  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module io_mapper (
	// DUT
	output wire        drv_weak,
	output wire        drv_strong,
	input  wire  [7:0] sense,

	// Bus interface
	input  wire  [3:0] wb_addr,
	output reg  [31:0] wb_rdata,
	input  wire [31:0] wb_wdata,
	input  wire        wb_we,
	input  wire        wb_cyc,
	output reg         wb_ack,

	// Clock / Reset
	input  wire clk,
	input  wire rst
);

	genvar i;

	// Signals
	// -------

	// Bus
	wire       bus_we_rst;
	wire       bus_rd_clr;

	reg        bus_we_drive;
	reg        bus_we_sense;

	// Drive
	reg  [1:0] drive_o;
	reg  [1:0] drive_oe;

	// Sense
	reg  [3:0] sense_tick_cnt;
	wire       sense_tick;

	reg [16:0] sense_cnt;
	wire       sense_active;

	wire [7:0] sense_io;
	reg  [7:0] sense_ior;

	reg [15:0] sense_hi[0:7];
	reg [15:0] sense_lo[0:7];


	// Bus Interface
	// -------------

	// Ack
	always @(posedge clk)
		wb_ack <= wb_cyc & ~wb_ack;

	// Write enables
	assign bus_we_rst = rst | wb_ack | ~wb_cyc | ~wb_we;

	always @(posedge clk)
		if (bus_we_rst) begin
			bus_we_drive <= 1'b0;
			bus_we_sense <= 1'b0;
		end else begin
			bus_we_drive <= (wb_addr == 4'h0);
			bus_we_sense <=  wb_addr[3];
		end

	// Read mux
	assign bus_rd_clr = wb_ack | ~wb_cyc;

	always @(posedge clk)
		if (bus_rd_clr)
			wb_rdata <= 32'h00000000;
		else
			case (wb_addr[2:0])
				3'b000:  wb_rdata <= { sense_hi[0], sense_lo[0] };
				3'b001:  wb_rdata <= { sense_hi[1], sense_lo[1] };
				3'b010:  wb_rdata <= { sense_hi[2], sense_lo[2] };
				3'b011:  wb_rdata <= { sense_hi[3], sense_lo[3] };
				3'b100:  wb_rdata <= { sense_hi[4], sense_lo[4] };
				3'b101:  wb_rdata <= { sense_hi[5], sense_lo[5] };
				3'b110:  wb_rdata <= { sense_hi[6], sense_lo[6] };
				3'b111:  wb_rdata <= { sense_hi[7], sense_lo[7] };
				default: wb_rdata <= 32'hxxxxxxxx;
			endcase

	// Drive control
	always @(posedge clk or posedge rst)
		if (rst) begin
			drive_oe <= 2'b00;
			drive_o  <= 2'b00;
		end else if (bus_we_drive) begin
			drive_oe <= wb_wdata[3:2];
			drive_o  <= wb_wdata[1:0];
		end


	// IOBs
	// ----

	// Drive
	SB_IO #(
		.PIN_TYPE(6'b1101_01),
		.PULLUP(1'b0)
	) iob_drive_I[1:0] (
		.PACKAGE_PIN  ({drv_strong, drv_weak}),
		.OUTPUT_CLK   (clk),
		.OUTPUT_ENABLE(drive_oe),
		.D_OUT_0      (drive_o)
	);

	// Sense
	SB_IO #(
		.PIN_TYPE(6'b000000),
		.PULLUP(1'b0)
	) iob_sense_I[7:0] (
		.PACKAGE_PIN  (sense),
		.INPUT_CLK    (clk),
		.D_IN_0       (sense_io)
	);

	always @(posedge clk)
		sense_ior <= sense_io;


	// Tick gen
	// --------

	always @(posedge clk)
		if (sense_tick)
			sense_tick_cnt <= 4'h0;
		else
			sense_tick_cnt <= sense_tick_cnt + 1;

	assign sense_tick = sense_tick_cnt[3];


	// Counters
	// --------

	// Limit counter
	always @(posedge clk)
		if (bus_we_sense)
			sense_cnt <= 17'h1fffe;
		else
			sense_cnt <= sense_cnt - (sense_active & sense_tick);

	assign sense_active = sense_cnt[16];

	// Count 0/1 for each sense line
	generate
		for (i=0; i<8; i=i+1)
		begin
			// Hi counter
			always @(posedge clk)
				if (bus_we_sense)
					sense_hi[i] <= 0;
				else
					sense_hi[i] <= sense_hi[i] + ((sense_tick & sense_active & sense_ior[i]) ? 1 : 0);

			// Lo counter
			always @(posedge clk)
				if (bus_we_sense)
					sense_lo[i] <= 0;
				else
					sense_lo[i] <= sense_lo[i] + ((sense_tick & sense_active & ~sense_ior[i]) ? 1 : 0);
		end
	endgenerate

endmodule // io_mapper
