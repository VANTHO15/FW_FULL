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
from compile import Compile
from debug import Debug
from report import Report
from run import Run
from clean import Clean

from common import Make_Dir

def Read_argument():
    # init parser
    parser = argparse.ArgumentParser(description="write args")
    # Options for tool
    parser.add_argument("-o", "--options", help="clean generate compile debug report", nargs='+', default=None)
    return parser.parse_args()

class mTest(): # chứa các biến đầu vào input
     # Lấy user config
    UserConfig_variable = "UserConfig.py"
    if os.path.exists(UserConfig_variable):
        exec(open(UserConfig_variable).read())
    
    PathGetvariableFromConfig = f'{PRO_DIR}/../env_{COMPILER}/env.py'
    if os.path.exists(PathGetvariableFromConfig):
        exec(open(PathGetvariableFromConfig).read())

    # get XDM_FILE in TS
    PathGetDirFromTS = f'{TEST_DIR}/{TEST_NAME}/{TEST_NAME}.py'
    print(PathGetDirFromTS)
    if os.path.exists(PathGetDirFromTS):
        exec(open(PathGetDirFromTS).read())
    
    # get source files
    for SRC in SRC_DIRS:
        SRC_FILES += glob.glob(os.path.join(SRC,"*.c"))
        SRC_FILES += glob.glob(os.path.join(SRC,"*.s"))


class mRunTool():
    def __init__(self, step):
        self.Step = step
        self.Mytest = mTest()
        print("")
        logging.info("Initial SUCCEEDED")
        print("")

    def Start(self):
        if self.Step == "eb":
            OpenEb(mTest=self.Mytest).Run()
        elif self.Step == "generate":
            Generate(mTest=self.Mytest).Run()
        elif self.Step == "compile":
            Compile(mTest=self.Mytest).Run()
        elif self.Step == "debug":
            Debug(mTest=self.Mytest, Debug = 1).Run()
        elif self.Step == "nodebug":
            Debug(mTest=self.Mytest, Debug = 2).Run()
        elif self.Step == "report":
            Report(mTest=self.Mytest).Run()
        elif self.Step == "run":
            Run(mTest=self.Mytest).Run()
        elif self.Step == "clean":
            Clean(mTest=self.Mytest).Run()
        else:
            print("Check steps again, please !")
        

if __name__ == '__main__':
    Argument = Read_argument()
    logging.info("options = %s ",Argument.options[0])
    RunNew = mRunTool(Argument.options[0])
    RunNew.Start()