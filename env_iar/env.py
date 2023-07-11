LINKER_FILE = f'{PRO_DIR}/../env_{COMPILER}/linker/ThoNV_stm32f407.icf'
LK_FILE = f'{COMPILER_DIR_IAR}/bin/ilinkarm.exe'
CC_FILE = f'{COMPILER_DIR_IAR}/bin/iccarm.exe'
AC_FILE = f'{COMPILER_DIR_IAR}/bin/iasmarm.exe'
POST_COMPILE = f'{COMPILER_DIR_IAR}/bin/ielftool.exe'

BIN_COMPILE_OPTS= [
    '--bin',
]

HEX_COMPILE_OPTS = [
    '--ihex'
]

CC_OPTS = [
    '-c',
    '--cpu=Cortex-M4',
    '--cpu_mode=thumb',
    '--endian=little',
    '--debug',
    '-Ohz'
]

LK_OPTS = [
    '--cpu=Cortex-M4',
    '--entry=Reset_Handler',
    '--config',
    f'{LINKER_FILE}',
    '--map',
    'MAP_FILE_REPLACE'
]
AC_OPTS = [
    '-r',
]