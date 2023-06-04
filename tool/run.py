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
# Liệt kê các file và thư mục 
from glob import glob
import os
import subprocess
from common import CommonStep,StepStatus  

class Run(CommonStep):
    def __init__(self, mTest):
        self.step = "Run"
        super().__init__(self.step, mTest.TEST_NAME)
        self.mTest = mTest
    def Run(self):
        self.LetStart()
        
        Hex_path = f'{self.mTest.OUTPUT_DIR}/compile/{self.mTest.TEST_NAME}.hex'
        with open("Temp_jlink.script","r") as file:
            Data = file.read()
        Data = Data.replace("PATH_HEX_REPLACE", Hex_path)

        with open("jlink.script", "w+") as file:
            file.write(Data) 
        
        subprocess.call([self.mTest.JLINK_FILE,'-device',self.mTest.DEVICE,'-if',self.mTest.DEBUGER_JTAG_SWD,"-speed","4000","-CommanderScript", "jlink.script"])
        
        self.Result = StepStatus.SUCCEEDED

        if os.path.exists("jlink.script"):
            os.remove("jlink.script")
        
        self.LetEnd()