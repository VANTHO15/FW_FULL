LINKER_FILE = f'{PRO_DIR}/../env_{COMPILER}/linker/ThoNV_stm32f407.ld'
LK_FILE = "C:/ghs/comp/elxr.exe"
CC_FILE = "C:/ghs/comp/ccarm.exe"
AC_FILE = "C:/ghs/comp/asarm.exe"
VERDION_FILE = "C:/ghs/comp/gversion.exe"
# POST_COMPILE = f'{COMPILER_DIR_IAR}/bin/ielftool.exe'

BIN_COMPILE_OPTS= [
    '--bin',
]

HEX_COMPILE_OPTS = [
    '--ihex'
]

CC_OPTS = [
    '-c',
    '--cpu=Cortex-M4',
    '-Osize',
    '-Wall',
    '-ansi',
    '-G',
    '-preprocess_assembly_files',
    '--no_exceptions',
    '-dual_debug',
    '--prototype_errors',
    '-Wundef',
    '-noslashcomment',
    '-Wimplicit-int',
    '-Wshadow',
    '-Wtrigraphs',
    '--no_commons',
    '--incorrect_pragma_warnings',
    '-keeptempfiles',
    '--short_enum',
    '--gnu_asm',
    '--ghstd=last',
    '-Odebug'
]

LK_OPTS = [
    '-LC:/ghs/comp/lib/thumb2', 
    '-lmath_sf', 
    '-lstartup', 
    '-lsys', 
    '-larch', 
    '-lansi', 
    '-lutf8_s32', 
    '-Mn -delete', 
    '-v', 
    '-ignore_debug_references', 
    '-map', 
    '-keepmap', 
    '-physical_address_offset=0', 
    f'{LINKER_FILE}',
]
AC_OPTS = [
    '--cpu=Cortex-M4',
    '-list',
    '-dwarf2'
]