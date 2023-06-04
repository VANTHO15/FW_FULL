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
import glob
import os

# Sao cheps file shutil.copy (src, dst)
import shutil

from common import CommonStep,Make_Dir,StepStatus

class Clean(CommonStep):
    def __init__(self, mTest):
        self.mTest = mTest
        self.Step = "Clean"
        self.OutputTest = os.path.normpath(mTest.OUTPUT_DIR)
        super().__init__(self.Step, mTest.TEST_NAME)
    
    def Run(self):
        self.LetStart()
        logging.info(f"Clean folder output : {self.OutputTest}")
        try:
            shutil.rmtree(self.OutputTest)
            self.Result = StepStatus.SUCCEEDED
        except Exception as e:
            logging.info(e)
        self.LetEnd()

