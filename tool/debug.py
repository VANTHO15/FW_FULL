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
from glob import glob
import subprocess
import signal

from openebtresos import OpenEb
from generate import Generate

from common import CommonStep,Make_Dir,StepStatus,ConvertDumpLog

def Read_argument():
    # init parser
    parser = argparse.ArgumentParser(description="write args")
    # Options for tool
    parser.add_argument("-o", "--options", help="prepare generate compile execute report", nargs='+', default=None)
    return parser.parse_args()

# Regular Expression (RegEx) 
# ^a...s$
# Đoạn code trên xác định quy tắc RegEx: bất kỳ chuỗi nào có năm chữ cái, bắt đầu bằng a và kết thúc bằng s.
import re

JDEBUG_FILE_GCC = r'debug_gcc.jdebug'
JDEBUG_FILE_IAR = r'debug_iar.jdebug'

class Debug(CommonStep):
    def __init__(self, mTest, Debug):
        self.step = "debug"
        super().__init__(self.step, mTest.TEST_NAME)
        self.mTest = mTest
        self.Debug = Debug
        self.mTest.OZONE_FILE = os.path.normpath(mTest.OZONE_FILE)
        output = os.path.normpath(self.mTest.OUTPUT_DIR)
        self.DumpFile = os.path.join(output, "debug", "result", "dump.log")
        self.RunLogFile = os.path.join(output, "debug", "result", "run.log")
        self.ResultFile = os.path.join(output, "debug", "result", "result.log")
        self.Project = os.path.join(output, "compile")
        Make_Dir(os.path.join(output, "debug", "result"))
        self.MapFile = glob(os.path.join(self.Project, "*.map"))[0]

    def Run(self):
        self.LetStart()

        ResultAddress_pattern  = ""
        EndTestAddress_pattern  = ""
        if self.mTest.DEBUGER == "ozone": 
            try:
                if self.mTest.COMPILER == "gcc" or self.mTest.COMPILER == "gcc_c":
                    ResultAddress_pattern  = "\s+(\w+)\s+TestCaseResult"
                    EndTestAddress_pattern  = "\s+(\w+)\s+ThoNVEnd"
                elif self.mTest.COMPILER == "iar":
                    ResultAddress_pattern  = "TestCaseResult\s*(0x\S*)"
                    EndTestAddress_pattern  = "ThoNVEnd\s*(0x\S*)"
                elif self.mTest.COMPILER == "ghs":
                    ResultAddress_pattern  = "\s+(\w+)\+\w+\sTestCaseResult"
                    EndTestAddress_pattern  = "\s+(\w+)\+\w+\sThoNVEnd"
                print(ResultAddress_pattern)
                with open(self.MapFile, "r") as file:
                    MapFileData = file.read()
                    # re.findall Nó trả về một danh sách chứa tất cả các kết quả khớp của một mẫu trong chuỗi.
                    ResultAddress = re.findall(ResultAddress_pattern , MapFileData)[0].replace("'", "")
                    EndTestAddress = re.findall(EndTestAddress_pattern , MapFileData)[0].replace("'", "")
                self.ElfFile = glob(os.path.join(self.Project, "*.elf"))[0]  
            except:
                logging.error("Do not find pattern in Map file")
                exit()
        if (self.mTest.JLINK_INTERFACE == "USB"):
            Temp = self.mTest.JLINK_SERIAL_NUMBER
        else:
            Temp = self.mTest.JLINK_IP   
        LIST_REP = {"TARGET_JDEBUG":self.mTest.DEVICE,"HostIF_JDEBUG":Temp,"ELF_FILE_JDEBUG":self.ElfFile,
                        "END_OF_TEST_JDEBUG": EndTestAddress,"DUMP_FILE": self.DumpFile,"RESULT_ADDRESS_JDEBUG": ResultAddress,
                        "DEBUG_MODE_JDEBUG":str(self.Debug), "CONSOLE_FILE_JDEBUG":self.RunLogFile, "IF_TMP_JDEBUG": self.mTest.JLINK_INTERFACE,
                        "DEBUG_INTERFACE": self.mTest.DEBUGER_JTAG_SWD}
        
        if self.mTest.COMPILER == "gcc" or self.mTest.COMPILER == "gcc_c":
            with open(JDEBUG_FILE_GCC,"r") as file:
                JdebugData = file.read()
        elif self.mTest.COMPILER == "iar":
            with open(JDEBUG_FILE_IAR,"r") as file:
                JdebugData = file.read()
        elif self.mTest.COMPILER == "ghs":
            with open(JDEBUG_FILE_GCC,"r") as file:
                JdebugData = file.read()
        
        for key,value in LIST_REP.items():
            JdebugData = JdebugData.replace(key,value)

        
        DebugFile = os.path.join(self.Project,self.TestName+".jdebug")
        DebugFileOld = os.path.join(self.Project,self.TestName+".jdebug.user")
        if os.path.exists(DebugFileOld):
            os.remove(DebugFileOld)
            
        with open(DebugFile, "w+") as file:
            file.write(JdebugData)
        
        DebugOptions = [ '-project', DebugFile]
        Command = [self.mTest.OZONE_FILE] + DebugOptions

        Result, AllLog = CommonStep.RunCmd(Command)

        if Result:
            ConvertDumpLog(self.DumpFile, self.ResultFile)
            self.Result = StepStatus.SUCCEEDED
        else:
            self.Result = StepStatus.FAILED

        self.LetEnd()
    

