LINKER_FILE = f'{PRO_DIR}/../env_{COMPILER}/linker/ThoNV_stm32f407.icf'
LK_FILE = f'{COMPILER_DIR_GCC}/bin/ilinkarm.exe'
CC_FILE = f'{COMPILER_DIR_GCC}/bin/iccarm.exe'
AC_FILE = f'{COMPILER_DIR_GCC}/bin/iasmarm.exe'
POST_COMPILE = f'{COMPILER_DIR_GCC}/bin/ielftool.exe'

BIN_COMPILE_OPTS= [
    '--bin',
]

HEX_COMPILE_OPTS = [
    '-O',
    'ihex'
]

CC_OPTS = [
    '-c',
    '-mcpu=cortex-m4',
    '-mthumb',
    '-mlittle-endian',
    '-O0',
    '-g'
]

LK_OPTS = [
    f'-Wl,-Map,MAP_FILE_REPLACE',
    '--entry=Reset_Handler',
    '-specs=nano.specs',
    '-specs=nosys.specs',
    '-mcpu=cortex-m4',
    '-mlittle-endian',
    '-n',
    '-T',
    f'{LINKER_FILE}'
]
AC_OPTS = [
    '-c',
    '-mthumb',
    '-mcpu=cortex-m4',
    '-x',
    'assembler-with-cpp'
]