MEMORY
{
    ROM (rx)    : ORIGIN = 0x10000000, LENGTH = 0x1000
}
ENTRY(_start)
SECTIONS {
    .text :
    {
        . = ALIGN(4);
        *(.text.start)
        *(.text)
        *(.text*)
    } >ROM
}
