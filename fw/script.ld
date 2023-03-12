ENTRY(_start)

MEMORY
{
    ROM(x) : ORIGIN = 0, LENGTH = 1024
    RAM(rw) : ORIGIN = 0, LENGTH = 1024
}

SECTIONS
{
    .text : {
        *(.text._start)
        *(.text*)
    } > ROM

    .rodata : {
        *(.rodata*)
    } > ROM

    .stack : {
        *(.bss._stack)
    } > RAM

    .bss : {
        *(.bss*)
    } > RAM

    .data : {
        *(.data*)
    } > RAM

    /DISCARD/ : {
        *(.note.gnu.build-id)
    }
}
