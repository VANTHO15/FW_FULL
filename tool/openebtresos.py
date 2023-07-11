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
from common import CommonStep,StepStatus

class OpenEb(CommonStep):
    def __init__(self, mTest):
        # Nhận class và Lấy, Tạo các đường dẫn,folder
        self.Step = "OpenEBTRESOS"
        # Truyền step và test name cho  CommonStep
        super().__init__(self.Step, "EB_Tresos")
        self.EbBatFile = os.path.join(mTest.EB_DIR, "bin", "tresos_gui.exe")
    def Run(self):
        self.LetStart()

        Command = [self.EbBatFile]
        Result,Log = CommonStep.RunCmd(Command)
        if Result:
            self.Result = StepStatus.SUCCEEDED
        else:
            self.Result = StepStatus.FAILED
        
        self.LetEnd()
    