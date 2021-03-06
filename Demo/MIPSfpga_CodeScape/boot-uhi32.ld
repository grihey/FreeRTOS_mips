/* The following TEXT start address leaves space for the monitor
   workspace.  This linker script links ISA32r2 programs for use with
   the simulator.  */

ENTRY(_start)
OUTPUT_FORMAT("elf32-tradlittlemips", "elf32-tradbigmips", "elf32-tradlittlemips")
GROUP(-lc -luhi -lgcc -lhal)
SEARCH_DIR(.)
__DYNAMIC  =  0;
STARTUP(crt0.o)
EXTERN(__exception_entry)
EXTERN(__getargs)

/*
 * Allocate the stack to be at the top of memory, since the stack
 * grows down
 */
PROVIDE (__stack = 0);
/* PROVIDE (__global = 0); */

/* Size of the memory returned by get_mem_info */
PROVIDE (__memory_size = 1M);

/*!!! Custom defined with no understandig a consequences */
PROVIDE (__isr_vec_space = 32);

/* 
 * 0 = Do not use exception handler present in boot
 * 1 = Use exception handler present in boot if BEV is 0 at startup
 * 2 = Always use exception handler present in boot
*/
PROVIDE (__use_excpt_boot = 0);

/*
 * Initalize some symbols to be zero so we can reference them in the
 * crt0 without core dumping. These functions are all optional, but
 * we do this so we can have our crt0 always use them if they exist.
 * This is so BSPs work better when using the crt0 installed with gcc.
 * We have to initalize them twice, so we multiple object file
 * formats, as some prepend an underscore.
 */
PROVIDE (hardware_exit_hook = 0);
PROVIDE (hardware_hazard_hook = 0);
PROVIDE (hardware_init_hook = 0);
PROVIDE (software_init_hook = 0);

/* The default base address for application code is 0x80200000 which
   leaves 2M of space at the start of KSEG0 for a bootloader. */

/*Commented cause it defined in Makefile, why reprovide it?*/
/* PROVIDE (__app_start = 0x80200000); */

/*
 * The start of flash must be set if including boot code.  By default
 * the use of boot code will mean that application code is copied
 * from flash to RAM at runtime before being executed.
*/
PROVIDE (__flash_start = __app_start);

SECTIONS
{
  /* Start of bootrom */
  .bootrom 0x9fc00000 : /* Runs uncached (from 0x9fc00000) until I$ is
			   initialized. */
  AT (__flash_start)
  {
    *(.reset)		/* Reset entry point. */
    *(.boot)		/* Boot code. */
    . = ALIGN(8);
  } = 0

  PROVIDE (__flash_app_start = SIZEOF(.bootrom) + __flash_start);

  /* Start of the application */
  .exception_vector ALIGN(__app_start, 0x1000) :
  AT (__flash_app_start)
  {
    __excpt_ebase = ABSOLUTE(.);
    __base = .;
    KEEP(* (.text.__exception_entry))
    . = ALIGN(8);
  } = 0

  .text (__excpt_ebase + 0x218) : {
     /* _ftext = . ; */
    /* PROVIDE (eprol  =  .); */
    *(.text)
    *(.text.*)
    *(.gnu.linkonce.t.*)
    *(.mips16.fn.*)
    *(.mips16.call.*)
  }
  .init : {
    KEEP (*(.init))
  }
  .fini : {
    KEEP (*(.fini))
  }
  .rel.sdata : {
    PROVIDE (__runtime_reloc_start = .);
    *(.rel.sdata)
    PROVIDE (__runtime_reloc_stop = .);
  }
  PROVIDE (etext  =  .);
  _etext  =  .;

  .eh_frame_hdr : { *(.eh_frame_hdr) }
  .eh_frame : { KEEP (*(.eh_frame)) }
  .gcc_except_table : { *(.gcc_except_table) }
  .jcr : { KEEP (*(.jcr)) }
  .ctors    :
  {
    /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */

    KEEP (*crtbegin.o(.ctors))

    /* We don't want to include the .ctor section from
       from the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */

    KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
  }

  .dtors    :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
  }

  . = .;
  .MIPS.abiflags : {
    __MIPS_abiflags_start = .;
    *(.MIPS.abiflags)
    __MIPS_abiflags_end = .;
  }
  .rodata : {
    *(.rdata)
    *(.rodata)
    *(.rodata.*)
    *(.gnu.linkonce.r.*)
  }
   _fdata = ALIGN(16);
  .data : {
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d.*)
  }
  . = ALIGN(4);
  _gp = . + 0x8001; 
  __global = _gp;
  .lit8 : {
    *(.lit8)
  }
  .lit4 : {
    *(.lit4)
  }
  .sdata : {
    *(.sdata)
    *(.sdata.*)
    *(.gnu.linkonce.s.*)
  }
  . = ALIGN(4);
  PROVIDE (edata  =  .);
  _edata  =  .;
  _fbss = .;
  .sbss : {
    *(.sbss)
    *(.sbss.*)
    *(.gnu.linkonce.sb.*)
    *(.scommon)
  }
  .bss : {
    _bss_start = . ;
    *(.bss)
    *(.bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
  }

  . = ALIGN(4);
  PROVIDE (end = .);
  _end = .;

  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to
     the beginning of the section so we begin them at 0.  */

  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }

  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }

  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }

  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  .debug_ranges   0 : { *(.debug_ranges) }

  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }

  /* Special sections generated by gcc */
  /* Newer GNU linkers strip by default */
  .mdebug.abi32            0 : { KEEP(*(.mdebug.abi32)) }
  .mdebug.abiN32           0 : { KEEP(*(.mdebug.abiN32)) }
  .mdebug.abi64            0 : { KEEP(*(.mdebug.abi64)) }
  .mdebug.abiO64           0 : { KEEP(*(.mdebug.abiO64)) }
  .mdebug.eabi32           0 : { KEEP(*(.mdebug.eabi32)) }
  .mdebug.eabi64           0 : { KEEP(*(.mdebug.eabi64)) }
  .gcc_compiled_long32     0 : { KEEP(*(.gcc_compiled_long32)) }
  .gcc_compiled_long64     0 : { KEEP(*(.gcc_compiled_long64)) }
}
