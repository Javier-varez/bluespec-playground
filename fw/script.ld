ENTRY(_start)

MEMORY
{
    RAM(rwx) : ORIGIN = 0, LENGTH = 1024
}

SECTIONS
{
    .text : {
        *(.text._start)
        *(.text*)
    } > RAM

    .rodata : {
        *(.rodata*)
    } > RAM

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
