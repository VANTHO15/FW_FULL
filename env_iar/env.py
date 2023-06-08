LINKER_FILE = f'{PRO_DIR}/../env_{COMPILER}/linker/ThoNV_stm32f407.icf'
LK_FILE = f'{COMPILER_DIR_IAR}/bin/ilinkarm.exe'
CC_FILE = f'{COMPILER_DIR_IAR}/bin/iccarm.exe'
AC_FILE = f'{COMPILER_DIR_IAR}/bin/iasmarm.exe'
POST_COMPILE = f'{COMPILER_DIR_IAR}/bin/ielftool.exe'

BIN_COMPILE_OPTS= [
    '--bin',
]

HEX_COMPILE_OPTS = [
    '-O',
    'ihex'
]

CC_OPTS = [
    '-c',
    '--cpu=Cortex-M4',
    '--cpu_mode=thumb',
    '--endian=little',
    '--fpu=FPv4-SP',
    '--debug',
    '-Ohz',
    '--no_clustering',
    '--no_mem_idioms',
    '-DI_CACHE_ENABLE',
    '--do_explicit_zero_opt_in_named_sections',
    '--diag_suppress=Pa050'
]

LK_OPTS = [
    '--cpu=Cortex-M4',
    '--fpu=FPv5-SP',
    '--entry=Reset_Handler',
    '--enable_stack_usage',
    '--no_wrap_diagnostics',
    '--enable_stack_usage',
    '--skip_dynamic_initialization',
    '--config',
    f'{LINKER_FILE}',
    '--map',
    'MAP_FILE_REPLACE'
]
AC_OPTS = [
    # '--cpu=Cortex-M4',
    # '--cpu_mode=thumb',
    '-r'
]