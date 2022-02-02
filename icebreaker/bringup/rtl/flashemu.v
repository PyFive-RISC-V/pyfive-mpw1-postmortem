/*
 * flashemu.v
 *
 * Dumb and simple flash emulation. Just enough for what we need.
 * Note that spi_clk needs to be much lower than 'clk'.
 *
 * vim: ts=4 sw=4
 *
 * Copyright (C) 2021-2022  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module flashemu (
	// SPI flash
	input  wire spi_mosi,
	output wire spi_miso,
	input  wire spi_cs_n,
	input  wire spi_clk,

	// Memory write port
	input  wire [31:0] mem_wr_data,
	input  wire [15:0] mem_wr_addr,
	input  wire        mem_wr_ena,

	// Monitor port
	output wire [7:0] mon_cmd,
	output wire       mon_stb,

	// Clock / Reset
	input  wire clk,
	input  wire rst
);

	// Signals
	// -------

	// FSM
	localparam [2:0]
		ST_IDLE       = 0,
		ST_CMD        = 1,
		ST_OTHER      = 2,
		ST_READ_ADDR0 = 3,
		ST_READ_ADDR1 = 4,
		ST_READ_ADDR2 = 5,
		ST_READ_DATA  = 6;

	reg [2:0] state;
	reg [2:0] state_nxt;

	// Access
	reg  [23:0] addr;

	// Memory
	reg  [31:0] mem_storage[0:1024];
	wire [23:0] mem_rd_addr;
	reg   [1:0] mem_rd_addr_lsb_r;
	reg  [31:0] mem_rd_data_word;
	reg   [7:0] mem_rd_data;

	// IOs
	reg [1:0] io_mosi_r;
	reg [1:0] io_csn_r;
	reg [1:0] io_clk_r;

	wire      io_mosi;
	wire      io_miso;
	wire      io_csn;
	wire      io_clk;

	reg       evt_clk_rise;
	reg       evt_clk_fall;
	reg       evt_csn_fall;

	// Shifter
	reg [3:0] sui_cnt;
	wire      sui_cnt_last;

	reg  [7:0] sui_in_data;
	reg        sui_in_stb;
	wire [7:0] sui_out_data;
	reg  [7:0] sui_out_shift;
	reg        sui_out_stb;


	// FSM
	// ---

	// State register
	always @(posedge clk)
		if (rst)
			state <= ST_IDLE;
		else
			state <= state_nxt;

	// Next-state logic
	always @(*)
	begin
		// Default
		state_nxt = state;

		// State transitions
		case (state)
		ST_IDLE:
			if (evt_csn_fall)
				state_nxt = ST_CMD;

		ST_CMD:
			if (sui_in_stb)
				state_nxt = (sui_in_data == 8'h03) ? ST_READ_ADDR0 : ST_OTHER;

		ST_OTHER:
			if (io_csn)
				state_nxt = ST_IDLE;

		ST_READ_ADDR0:
			if (sui_in_stb)
				state_nxt = ST_READ_ADDR1;

		ST_READ_ADDR1:
			if (sui_in_stb)
				state_nxt = ST_READ_ADDR2;

		ST_READ_ADDR2:
			if (sui_in_stb)
				state_nxt = ST_READ_DATA;

		ST_READ_DATA:
			if (io_csn)
				state_nxt = ST_IDLE;
		endcase

		// Reset
		if (io_csn)
			state_nxt = ST_IDLE;
	end


	// Monitor
	// -------

	assign mon_cmd = sui_in_data;
	assign mon_stb = (state == ST_CMD) & sui_in_stb;


	// Data read
	// ---------

	// Adress register
	always @(posedge clk)
	begin
		if (sui_in_stb) begin
			if (state == ST_READ_ADDR0)
				addr[23:16] <= sui_in_data;
			else if (state == ST_READ_ADDR1)
				addr[15:8] <= sui_in_data;
			else if (state == ST_READ_ADDR2)
				addr[7:0] <= sui_in_data + 1;
			else if (state == ST_READ_DATA)
				addr <= addr + 1;
		end
	end

	// Address mux
	assign mem_rd_addr = (state == ST_READ_ADDR2) ? { addr[23:8], sui_in_data } : addr;

	// Memory
	always @(posedge clk)
	begin
		mem_rd_addr_lsb_r <= mem_rd_addr[1:0];
		mem_rd_data_word <= mem_storage[mem_rd_addr[11:2]];

		if (mem_wr_ena)
			mem_storage[mem_wr_addr[9:0]] <= mem_wr_data;
	end

	always @(*)
	begin
		case (mem_rd_addr_lsb_r)
			2'b00:   mem_rd_data = mem_rd_data_word[ 7: 0];
			2'b01:   mem_rd_data = mem_rd_data_word[15: 8];
			2'b10:   mem_rd_data = mem_rd_data_word[23:16];
			2'b11:   mem_rd_data = mem_rd_data_word[31:24];
			default: mem_rd_data = 8'hxx;
		endcase
	end

	// Send data
	assign sui_out_data = (state == ST_READ_DATA) ? mem_rd_data : 8'h00;


	// Shifter unit
	// ------------

	// Register inputs
	always @(posedge clk)
	begin
		io_mosi_r <= { io_mosi_r[0], spi_mosi };
		io_csn_r  <= { io_csn_r[0],  spi_cs_n };
		io_clk_r  <= { io_clk_r[0],  spi_clk  };

		evt_clk_rise <= ~io_clk_r[1] &  io_clk_r[0];
		evt_clk_fall <=  io_clk_r[1] & ~io_clk_r[0];
		evt_csn_fall <=  io_csn_r[1] & ~io_csn_r[0];
	end

	assign io_mosi = io_mosi_r[1];
	assign io_csn  = io_csn_r[1] ;
	assign io_clk  = io_clk_r[1];

	// Output
	assign spi_miso = io_miso;

	// Bit count
	always @(posedge clk)
		if (io_csn)
			sui_cnt <= 4'h6;
		else if (evt_clk_rise)
			sui_cnt <= {1'b0, sui_cnt[2:0]} - 1;

	// Input shift register
	always @(posedge clk)
		if (evt_clk_rise)
			sui_in_data <= { sui_in_data[6:0], io_mosi };

	always @(posedge clk)
		sui_in_stb <= sui_cnt[3] & evt_clk_rise;

	// Output shift register
	always @(posedge clk)
		if (evt_csn_fall)
			sui_out_shift <= 8'h00;
		else if (sui_out_stb)
			sui_out_shift <= sui_out_data;
		else if (evt_clk_rise)
			sui_out_shift <= { sui_out_shift[6:0], 1'b0 };

	always @(posedge clk)
		sui_out_stb <= sui_in_stb;

	assign io_miso = sui_out_shift[7];

endmodule // flashemu
