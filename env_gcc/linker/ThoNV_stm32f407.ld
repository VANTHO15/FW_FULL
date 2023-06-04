ENTRY(Reset_Handler)

/*
* FLASH(rx):ORIGIN =0x08000000,LENGTH =1024K
* SRAM(rwx):ORIGIN =0x20000000,LENGTH =128K
*/

MEMORY
{
    int_flash_c0               : ORIGIN = 0x08000000, LENGTH = 0x000F9F00    /* 1792K - 256b */
    int_flash_fls_rsv_c0       : ORIGIN = 0x080F9F00, LENGTH = 0x00000100    /* 0.1K */

    int_sram_c0                : ORIGIN = 0x20000000, LENGTH = 0x00013880    /* 80K */
    int_sram_fls_rsv_c0        : ORIGIN = 0x20013880, LENGTH = 0x00000100    /* 0.1K */
	int_sram_stack_c0          : ORIGIN = 0x20013980, LENGTH = 0x00001E40    /* 77444  */
    int_sram_no_cacheable_c0   : ORIGIN = 0x200157C0, LENGTH = 0x00004E20    /* 20KB */
    int_sram_shareable         : ORIGIN = 0x2001A5E0, LENGTH = 0x00004E20    /* 20KB */
    ram_end_c0                 : ORIGIN = 0x2001F400, LENGTH = 0x00000000
}

HEAP_SIZE  = DEFINED(__heap_size__)  ? __heap_size__  : 0x00000200;

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

        __init_table = .;
        KEEP(*(.init_table))
        . = ALIGN(4);
        __init_table_end = .;

        __zero_table = .;
        KEEP(*(.zero_table))
        . = ALIGN(4);
        __zero_table_end = .;

        KEEP(*(.init))
        KEEP(*(.fini))
        . = ALIGN(4);
    } > int_flash_c0

    .flash_data :
    {
        . = ALIGN(4096);
        __init_vectortable_start = .;
        KEEP(*(.intc_vector))
        . = ALIGN(4);
        __init_vectortable_end = .;

        __init_data_start__ = .;
        *(.data)
        *(.data*)
        . = ALIGN(4);
        *(.mcal_data)
        . = ALIGN(4);
        *(.ramcode)
        . = ALIGN(4);
        __init_data_end__ = .;

        __init_data_nocache_start = .;
        *(.mcal_data_no_cacheable)
        . = ALIGN(4);
        *(.mcal_const_no_cacheable)
        . = ALIGN(4);
        __init_data_nocache_end = .;

        __init_data_shareable_start = .;
        *(.mcal_shared_data)
        . = ALIGN(4);
        __init_data_shareable_end = .;
    } > int_flash_c0

    .acfls_code_flash :
    {
        __acfls_code_rom_start = .;
        *(.acfls_code_rom) 
        . = ALIGN(4);
        __acfls_code_rom_end = .;
    } > int_flash_fls_rsv_c0

    .sram_data :
    {
        __data_start = .;
        . += __init_data_end__ - __init_data_start__;
        . = ALIGN(4);
        __data_end = .;
    } > int_sram_c0

    .sram_bss :
    {
        . = ALIGN(16);
        __bss_start__  = .;
        *(.bss)
        *(.bss*)
        . = ALIGN(16);
        *(.mcal_bss)
        . = ALIGN(4);
        __bss_end__  = .;
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
        __vectortable_start = .;
        . += __init_vectortable_end - __init_vectortable_start;
        . = ALIGN(4);
        __vectortable_end = .;

        __data_nocache_start = .;
        . += __init_data_nocache_end - __init_data_nocache_start;
        . = ALIGN(4);
        __data_nocache_end = .;

        __bss_nocache_start = .;
        *(.mcal_bss_no_cacheable)
        . = ALIGN(4);
        __bss_nocache_end = .;
    } > int_sram_no_cacheable_c0

    .sram_shareable :
    {
        __data_shareable_start = .;
        . += __init_data_shareable_end - __init_data_shareable_start;
        . = ALIGN(4);
        __data_shareable_end = .;
        
        __bss_shareable_start = .;
        *(.mcal_shared_bss )
        . = ALIGN(4);
        __bss_shareable_end = .;
    } > int_sram_shareable

    __Stack_end_c0              = ORIGIN(int_sram_stack_c0);
    __Stack_start_c0            = ORIGIN(int_sram_stack_c0) + LENGTH(int_sram_stack_c0);

    __INT_SRAM_START            = ORIGIN(int_sram_c0);
    __INT_SRAM_END              = ORIGIN(ram_end_c0);

    __VECTORTABLE_START         = __vectortable_start;
    __INIT_VECTORTABLE_START    = __init_vectortable_start;
    __INIT_VECTORTABLE_END      = __init_vectortable_end;
    __DATA_START                = __data_start;
    __INIT_DATA_START           = __init_data_start__;
    __INIT_DATA_END             = __init_data_end__;
    __DATA_NOCACHE_START        = __data_nocache_start;
    __INIT_DATA_NOCACHE_START   = __init_data_nocache_start;
    __INIT_DATA_NOCACHE_END     = __init_data_nocache_end;
    __DATA_SHAREABLE_START      = __data_shareable_start;
    __INIT_DATA_SHAREABLE_START = __init_data_shareable_start;
    __INIT_DATA_SHAREABLE_END   = __init_data_shareable_end;

    __BSS_START                 = __bss_start__ ;
    __BSS_END                   = __bss_end__ ;
    __BSS_NOCACHE_START         = __bss_nocache_start;
    __BSS_NOCACHE_END           = __bss_nocache_end;
    __BSS_SHAREABLE_START       = __bss_shareable_start;
    __BSS_SHAREABLE_END         = __bss_shareable_end;

    __INIT_TABLE                = __init_table;
    __INIT_TABLE_END            = __init_table_end;
    __ZERO_TABLE                = __zero_table;
    __ZERO_TABLE_END            = __zero_table_end;

    __RAM_INIT                  = 1;

    __ROM_CODE_START          = ORIGIN(int_flash_c0);
    __RAM_SHAREABLE_START     = ORIGIN(int_sram_shareable);
    __RAM_STACK_START         = ORIGIN(int_sram_stack_c0);
    __RAM_NO_CACHEABLE_START  = ORIGIN(int_sram_no_cacheable_c0);

    Fls_ACEraseRomStart         = __acfls_code_rom_start;
    Fls_ACEraseRomEnd           = __acfls_code_rom_end;
    Fls_ACEraseSize             = (__acfls_code_rom_end - __acfls_code_rom_start)/4;

    Fls_ACWriteRomStart         = __acfls_code_rom_start;
    Fls_ACWriteRomEnd           = __acfls_code_rom_end;
    Fls_ACWriteSize             = (__acfls_code_rom_end - __acfls_code_rom_start)/4;
    
    _ERASE_FUNC_ADDRESS_        = ADDR(.acfls_code_ram);
    _WRITE_FUNC_ADDRESS_        = ADDR(.acfls_code_ram);
}