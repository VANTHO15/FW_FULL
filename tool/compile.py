# lib parser
import argparse
# lib logging
import logging
logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.DEBUG,
    handlers=[logging.StreamHandler()],
    datefmt='%Y-%m-%d %H:%M:%S',
    format='[%(asctime)s %(levelname)s] --> %(module)s: %(message)s'
)

import os
import glob

from openebtresos import OpenEb
from generate import Generate

from common import CommonStep,Make_Dir,StepStatus

def Read_argument():
    # init parser
    parser = argparse.ArgumentParser(description="write args")
    # Options for tool
    parser.add_argument("-o", "--options", help="prepare generate compile execute report", nargs='+', default=None)
    return parser.parse_args()

class Compile(CommonStep):
    def __init__(self, mTest):
        self.Step = "compile"
        super().__init__(self.Step, mTest.TEST_NAME)
        self.mTest = mTest
        # create folder compile
        self.CompileDir = os.path.join(os.path.normpath(self.mTest.OUTPUT_DIR), "compile")
        Make_Dir(self.CompileDir)
        # create folder result
        Temp = os.path.join(self.CompileDir, "result")
        if not os.path.isdir(Temp):
            Make_Dir(Temp)
        self.ResultFile = os.path.join(Temp, "result.log")

        # Tạo path file Elf, bin, map  
        self.mTest.ELF_FILE =  f'{self.mTest.OUTPUT_DIR}/compile/{self.mTest.TEST_NAME}.elf'
        self.mTest.BIN_FILE =  f'{self.mTest.OUTPUT_DIR}/compile/{self.mTest.TEST_NAME}.bin'
        self.mTest.HEX_FILE =  f'{self.mTest.OUTPUT_DIR}/compile/{self.mTest.TEST_NAME}.hex'
        self.mTest.MAP_FILE =  os.path.normpath(f'{self.mTest.OUTPUT_DIR}/compile/{self.mTest.TEST_NAME}.map')

        # path folder generate
        self.GenDir = os.path.join(os.path.normpath(self.mTest.OUTPUT_DIR), "generate", mTest.GENERATOR)

    def Run(self):
        self.LetStart()

        # Lấy SRC_FILES và INCLUDE_DIRS của Eb tresos gen ra và tạo folder
        SRC_FILES = self.mTest.SRC_FILES + glob.glob(os.path.join(self.GenDir, "src", "*.c"))
        INCLUDE_DIRS = self.mTest.INCLUDE_DIRS + [os.path.join(self.GenDir, "include")]

        # Lấy linker Option
        LinkerOption = [opt.replace("MAP_FILE_REPLACE", self.mTest.MAP_FILE) for opt in self.mTest.LK_OPTS]
        ListCommands = []

        for SRC_FILE in SRC_FILES:
            # Chuyển file .c thành .o
            SRC_FILE = os.path.normpath(SRC_FILE)   # ví dụ  C://  -> C:/
            logging.info(f"File compile : {SRC_FILE}")
            Filename = os.path.basename(SRC_FILE) # Lấy tên của file
            Filename = f'{Filename[:-1]}o' # gpio.c -> gpio.o
            OutFile = os.path.join(self.CompileDir, Filename)
            LinkerOption += [OutFile]      # Thêm file .o vào linker option

            Opts = []
            if SRC_FILE[-2:] == ".c":
                for opt in self.mTest.CC_OPTS:
                    Opts += [opt]
                Opts += ["-c", SRC_FILE]
                for INCLUDE_DIR in INCLUDE_DIRS:
                    INCLUDE_DIR = os.path.normpath(INCLUDE_DIR)
                    Opts += [f'-I{INCLUDE_DIR}']
                Opts += ['-o', OutFile]
                Command = [self.mTest.CC_FILE] + Opts
                ListCommands.append(Command)
            elif SRC_FILE[-2:] == ".s":
                for opt in self.mTest.AC_OPTS:
                    Opts += [opt]
                Opts += [SRC_FILE]
                Opts += ["-o", OutFile]
                Command = [self.mTest.AC_FILE] + Opts
                ListCommands.append(Command)
        
        # Execute cái ListCommands trên
        for Cmd in ListCommands:
            Result, AllLog = CommonStep.RunCmd(Cmd)
        
        if Result:
            LinkerOption += ["-o"]
            LinkerOption += [f'{os.path.join(self.CompileDir, self.mTest.TEST_NAME)}.elf']
            Command = [self.mTest.LK_FILE] + LinkerOption
            Result, AllLog = CommonStep.RunCmd(Command)
            if Result:
                # BIN_FILE
                Options = []
                Options += self.mTest.BIN_COMPILE_OPTS
                Options.append(self.mTest.ELF_FILE)
                Options.append(self.mTest.BIN_FILE)
                Command = [os.path.normpath(self.mTest.POST_COMPILE)] + Options
                Result, AllLog = CommonStep.RunCmd(Command)

                # HEX_FILE
                Options = []
                Options += self.mTest.HEX_COMPILE_OPTS
                Options.append(self.mTest.ELF_FILE)
                Options.append(self.mTest.HEX_FILE)
                Command = [os.path.normpath(self.mTest.POST_COMPILE)] + Options
                Result, AllLog = CommonStep.RunCmd(Command)

        with open(self.ResultFile, "w+") as file:
            if Result is False:
                self.Result = StepStatus.FAILED
                file.write("0")
            else:
                self.Result = StepStatus.SUCCEEDED
                file.write("1")

        self.LetEnd()

