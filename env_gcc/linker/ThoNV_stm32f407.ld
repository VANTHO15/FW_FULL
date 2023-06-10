ENTRY(Reset_Handler)

/*
* FLASH(rx):ORIGIN =0x08000000,LENGTH =1024K
* SRAM(rwx):ORIGIN =0x20000000,LENGTH =128K
*/

MEMORY
{
    int_flash_c0               : ORIGIN = 0x08000000, LENGTH = 0x000F9F00    /* 1792K - 256b */
    int_flash_fls_rsv_c0       : ORIGIN = 0x080F9F00, LENGTH = 0x00000100    /* 0.1K */

    int_sram_c0                : ORIGIN = 0x20000000, LENGTH = 0x0000EA60    /* 60K */
    int_sram_fls_rsv_c0        : ORIGIN = 0x2000EA60, LENGTH = 0x00000100    /* 0.1K */
	int_sram_stack_c0          : ORIGIN = 0x2000EB60, LENGTH = 0x00006C60    /* 27744  */
    int_sram_no_cacheable_c0   : ORIGIN = 0x200157C0, LENGTH = 0x00004E20    /* 20KB */
    int_sram_shareable         : ORIGIN = 0x2001A5E0, LENGTH = 0x00004E20    /* 20KB */
    ram_end_c0                 : ORIGIN = 0x2001F400, LENGTH = 0x00000000
}

HEAP_SIZE  = DEFINED(heap_size)  ? heap_size  : 0x00000200;

SECTIONS
{
  	.flash :
    {
        *(.startup)
        *(.text.startup)
        *(.text)
        *(.text*)
        *(.mcal_text)
        *(.acmcu_code_rom)
        *(.rodata)
        *(.rodata*)
        *(.mcal_const_cfg)
        *(.mcal_const)

        init_table = .;
        KEEP(*(.init_table))
        . = ALIGN(4);
        init_table_end = .;

        zero_table = .;
        KEEP(*(.zero_table))
        . = ALIGN(4);
        zero_table_end = .;

        KEEP(*(.init))
        KEEP(*(.fini))
        . = ALIGN(4);
    } > int_flash_c0

    .flash_data :
    {
        . = ALIGN(4096);
        init_vectortable_start = .;
        KEEP(*(.intc_vector))
        . = ALIGN(4);
        init_vectortable_end = .;

        init_data_start = .;
        *(.data)
        *(.data*)
        . = ALIGN(4);
        *(.mcal_data)
        . = ALIGN(4);
        *(.ramcode)
        . = ALIGN(4);
        init_data_end = .;

        init_data_nocache_start = .;
        *(.mcal_data_no_cacheable)
        . = ALIGN(4);
        *(.mcal_const_no_cacheable)
        . = ALIGN(4);
        init_data_nocache_end = .;

        init_data_shareable_start = .;
        *(.mcal_shared_data)
        . = ALIGN(4);
        init_data_shareable_end = .;
    } > int_flash_c0

    .acfls_code_flash :
    {
        acfls_code_rom_start = .;
        *(.acfls_code_rom) 
        . = ALIGN(4);
        acfls_code_rom_end = .;
    } > int_flash_fls_rsv_c0

    .sram_data :
    {
        data_start = .;
        . += init_data_end - init_data_start;
        . = ALIGN(4);
        data_end = .;
    } > int_sram_c0

    .sram_bss :
    {
        . = ALIGN(16);
        bss_start  = .;
        *(.bss)
        *(.bss*)
        . = ALIGN(16);
        *(.mcal_bss)
        . = ALIGN(4);
        bss_end  = .;
    } > int_sram_c0

    .heap (NOLOAD):
    {
        . += ALIGN(4);
        _end = .;
        end = .;
        _heap_start = .;
        . += HEAP_SIZE;
        _heap_end = .;
    } > int_sram_c0

    .acfls_code_ram :
    {
        acfls_code_ram_start  = .;
        *(.acfls_code_ram)
        acfls_code_ram_stop   = .;
    } > int_sram_fls_rsv_c0

    .sram_nocache :
    {
        . = ALIGN(4096);
        vectortable_start = .;
        . += init_vectortable_end - init_vectortable_start;
        . = ALIGN(4);
        vectortable_end = .;

        data_nocache_start = .;
        . += init_data_nocache_end - init_data_nocache_start;
        . = ALIGN(4);
        data_nocache_end = .;

        bss_nocache_start = .;
        *(.mcal_bss_no_cacheable)
        . = ALIGN(4);
        bss_nocache_end = .;
    } > int_sram_no_cacheable_c0

    .sram_shareable :
    {
        data_shareable_start = .;
        . += init_data_shareable_end - init_data_shareable_start;
        . = ALIGN(4);
        data_shareable_end = .;
        
        bss_shareable_start = .;
        *(.mcal_shared_bss )
        . = ALIGN(4);
        bss_shareable_end = .;
    } > int_sram_shareable

    Stack_end_c0              = ORIGIN(int_sram_stack_c0);
    Stack_start_c0            = ORIGIN(int_sram_stack_c0) + LENGTH(int_sram_stack_c0);

    INT_SRAM_START            = ORIGIN(int_sram_c0);
    INT_SRAM_END              = ORIGIN(ram_end_c0);

    RAM_INIT                  = 1;
}