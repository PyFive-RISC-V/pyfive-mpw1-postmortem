Bringup HW Memory Map
=====================

`0x00000-0x0ffff`: DUT Global Control
-------------------------------------

```
0x00 : Clock / Reset control

	[7:6] Reset period (default = 11)

	[5:4] Reset length (default = 10)

	[3:2] Reset mode
		00 - Reset Asserted (default)
		01 - Reset Released
		1x - Reset Automatic

	[1:0] Clock divider Select
		00 - clk /  2
		01 - clk /  4
		10 - clk /  8 (default)
		11 - clk / 16

0x01 : VDD control
```


`0x10000-0x1ffff`: DUT Flash emulation
--------------------------------------

* All writes change the content of the emulated 2 kbytes of memory.
* All reads  return the number of flash commands received since the
  last DUT reset.


`0x20000-0x2ffff`: DUT UART
---------------------------

See `no2misc` for the `uart_wb` documentation.


`0x30000-0x3ffff`: IO mapper
----------------------------

```
0x00 : Drive control

	[3:2] {strong,weak} ouptut enable
	[1:0] {strong,weak} ouptut


0x08 - 0x0f : Sense counters

	[31:16] Hi count
	[15: 0] Lo count

	Write to reset
```
