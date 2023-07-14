
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
	int_sram_stack_c0          : ORIGIN = 0x20013980, LENGTH = 0x00006C60    /* 27744  */
    int_sram_no_cacheable_c0   : ORIGIN = 0x2001A5E0, LENGTH = 0x00002710    /* 10KB */
    int_sram_shareable         : ORIGIN = 0x2001CCF0, LENGTH = 0x00002710    /* 10KB */
    ram_end_c0                 : ORIGIN = 0x2001F400, LENGTH = 0x00000000
}

SECTIONS
{
  	.core_loop                                   ALIGN(4)     : > int_flash_c0
    .startup                                     ALIGN(4)     : > .
    .systeminit                                  ALIGN(4)     : > .
    .text.startup                                ALIGN(4)     : > .
    .text                                        ALIGN(4)     : > .
    .mcal_text                                   ALIGN(4)     : > .
    .acmcu_code_rom                              ALIGN(4)     : > .
    .rodata                                      ALIGN(4)     : > .
    .mcal_const_cfg                              ALIGN(4)     : > .
    .mcal_const                                  ALIGN(4)     : > .
    .init_table                                  ALIGN(4)     : > .
    .zero_table                                  ALIGN(4)     : > .
    .intc_vector                                 ALIGN(4096)  : > .
    .ROM.data                     ROM(.data)                    ALIGN(4)      : > .
    .ROM.mcal_data                ROM(.mcal_data)               ALIGN(4)      : > .
    .ROM.ramcode                  ROM(.ramcode)                 ALIGN(4)      : > .
    .ROM.mcal_data_no_cacheable   ROM(.mcal_data_no_cacheable)  ALIGN(4)      : > .
    .ROM.mcal_const_no_cacheable  ROM(.mcal_const_no_cacheable) ALIGN(4)      : > .
    .ROM.mcal_shared_data         ROM(.mcal_shared_data)        ALIGN(4)      : > .
    .acfls_code_rom                              ALIGN(4)     : > int_flash_fls_rsv_c0
    .data                                        ALIGN(4)     : > int_sram_c0
    .mcal_data                                   ALIGN(4)     : > .
    .ramcode                                 ABS ALIGN(4)     : > .
    .bss                                (NOLOAD) ALIGN(16)    : > .
    .mcal_bss                           (NOLOAD) ALIGN(16)    : > .
    .acfls_code_ram                              ALIGN(4)     : > .
    .intc_vector_ram                             ALIGN(4096)  PAD(SIZEOF(.intc_vector)) : > int_sram_no_cacheable_c0
    .mcal_data_no_cacheable                      ALIGN(4)     : > .
    .mcal_const_no_cacheable                     ALIGN(4)     : > .
    .mcal_bss_no_cacheable              (NOLOAD) ALIGN(16)    : > .
    .mcal_shared_data                            ALIGN(4)     : > int_sram_shareable
    .mcal_shared_bss                    (NOLOAD) ALIGN(16)    : > .

    __Stack_end_c0                = ADDR(int_sram_stack_c0);
    __Stack_start_c0              = ADDR(int_sram_stack_c0) + SIZEOF(int_sram_stack_c0);

    __INT_SRAM_START              = ADDR(int_sram_c0);
    __INT_SRAM_END                = ADDR(ram_end_c0);
    
    __INT_ITCM_START              = ADDR(int_itcm);
    __INT_ITCM_END                = ADDR(int_itcm) + SIZEOF(int_itcm);
                                  
    __INT_DTCM_START              = ADDR(int_dtcm);
    __INT_DTCM_END                = ADDR(int_dtcm) + SIZEOF(int_dtcm);
    
    __VECTORTABLE_START           = ADDR(.intc_vector_ram);
    __INIT_VECTORTABLE_START      = ADDR(.intc_vector);
    __INIT_VECTORTABLE_END        = ADDR(.intc_vector) + SIZEOF(.intc_vector);
    __DATA_START                  = ADDR(.data);
    __INIT_DATA_START             = ADDR(.ROM.data);
    __INIT_DATA_END               = ADDR(.ROM.ramcode) + SIZEOF(.ROM.ramcode);
    __DATA_NOCACHE_START          = ADDR(.mcal_data_no_cacheable);
    __INIT_DATA_NOCACHE_START     = ADDR(.ROM.mcal_data_no_cacheable);
    __INIT_DATA_NOCACHE_END       = ADDR(.ROM.mcal_const_no_cacheable) + SIZEOF(.ROM.mcal_const_no_cacheable);
    __DATA_SHAREABLE_START        = ADDR(.mcal_shared_data);
    __INIT_DATA_SHAREABLE_START   = ADDR(.ROM.mcal_shared_data);
    __INIT_DATA_SHAREABLE_END     = ADDR(.ROM.mcal_shared_data) + SIZEOF(.ROM.mcal_shared_data);
    __ROM_CODE_START              = ADDR(int_flash_c0);
    __RAM_STACK_START             = ADDR(int_sram_stack_c0);
    __RAM_NO_CACHEABLE_START      = ADDR(int_sram_no_cacheable_c0);
    __RAM_SHAREABLE_START         = ADDR(int_sram_shareable);
    
    __BSS_START                   = ADDR(.bss);
    __BSS_END                     = ADDR(.mcal_bss) + SIZEOF(.mcal_bss);
    __BSS_NOCACHE_START           = ADDR(.mcal_bss_no_cacheable);
    __BSS_NOCACHE_END             = ADDR(.mcal_bss_no_cacheable) + SIZEOF(.mcal_bss_no_cacheable);
    __BSS_SHAREABLE_START         = ADDR(.mcal_shared_bss);
    __BSS_SHAREABLE_END           = ADDR(.mcal_shared_bss) + SIZEOF(.mcal_shared_bss);
    
    __INIT_TABLE                  = ADDR(.init_table);
    __INIT_TABLE_END              = ADDR(.init_table) + SIZEOF(.init_table);
    __ZERO_TABLE                  = ADDR(.zero_table);
    __ZERO_TABLE_END              = ADDR(.zero_table) + SIZEOF(.zero_table);
                                  
    __RAM_INIT                    = 1;
    __ITCM_INIT                   = 1;
    __DTCM_INIT                   = 1;
    
    /* Fls module access code support */    
    Fls_ACEraseRomStart         = ADDR(.acfls_code_rom);
    Fls_ACEraseRomEnd           = ADDR(.acfls_code_rom) + SIZEOF(.acfls_code_rom);
    Fls_ACEraseSize             = (SIZEOF(.acfls_code_rom)+3) / 4;

    Fls_ACWriteRomStart         = ADDR(.acfls_code_rom);
    Fls_ACWriteRomEnd           = ADDR(.acfls_code_rom) + SIZEOF(.acfls_code_rom);
    Fls_ACWriteSize             = (SIZEOF(.acfls_code_rom)+3) / 4;
    
    _ERASE_FUNC_ADDRESS_        = ADDR(.acfls_code_ram);
    _WRITE_FUNC_ADDRESS_        = ADDR(.acfls_code_ram);
}