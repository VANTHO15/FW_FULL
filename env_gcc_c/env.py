LINKER_FILE = f'{PRO_DIR}/../env_{COMPILER}/linker/ThoNV_stm32f407.ld'
LK_FILE = CC_FILE = AC_FILE = f'{COMPILER_DIR_GCC}/bin/arm-none-eabi-gcc.exe'
POST_COMPILE = f'{COMPILER_DIR_GCC}/arm-none-eabi/bin/objcopy.exe'

BIN_COMPILE_OPTS= [
    '-O',
    'binary'
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