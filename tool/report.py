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

from datetime import datetime
from time import gmtime, strftime

from common import CommonStep,Make_Dir,StepStatus,ConvertResult

def Read_argument():
    # init parser
    parser = argparse.ArgumentParser(description="write args")
    # Options for tool
    parser.add_argument("-o", "--options", help="clean generate compile debug report", nargs='+', default=None)
    return parser.parse_args()

class Report(CommonStep):
    def __init__(self, mTest):
        self.Step = "report"
        self.mTest = mTest
        super().__init__(self.Step, mTest.TEST_NAME)
        self.ExecuteResults = os.path.join(mTest.OUTPUT_DIR, "debug", "result", "result.log")

    def Run(self):
        self.LetStart()

        DateTime = datetime.now().strftime("%d/%m/%Y %H:%M:%S ") + "GMT" + strftime("%z", gmtime())
        print(DateTime)

        with open(self.ExecuteResults, "r") as file:
            self.results = file.read().split('\n')
            print(self.results)
        
        # open html template file
        FILE_HTML = f'{self.mTest.PRO_DIR}/../env_{self.mTest.COMPILER}/temp_report/FileReport.html'
        with open(FILE_HTML, "r") as file:
            HtmlData = file.read()
        HtmlData = HtmlData.replace("TS_NAME", self.mTest.TEST_NAME)
        HtmlData = HtmlData.replace("COMPILER_NAME", self.mTest.COMPILER.upper())
        HtmlData = HtmlData.replace("TS_DESCRIPTION", self.mTest.TEST_NAME_DESCRIPTION)
        HtmlData = HtmlData.replace("DATE_TIME", DateTime)

        TC_ID = 1
        for TC in self.mTest.LIST_TC_OF_TS:
            HtmlData = HtmlData.replace("OFF_TC_"+str(TC_ID), "")
            HtmlData = HtmlData.replace("STATUS_TC_0"+str(TC_ID), ConvertResult(self.results[TC_ID-1]))
            HtmlData = HtmlData.replace("COLOR_TC_0"+str(TC_ID), ConvertResult(self.results[TC_ID-1]))
            HtmlData = HtmlData.replace("DES_TC_0"+str(TC_ID), self.mTest.LIST_TC_DESCRIPTION[TC_ID-1])
            HtmlData = HtmlData.replace("NAME_TC_0"+str(TC_ID), TC)
            # nếu có 1 cái fail thì cho TS FAIL
            if int(self.results[TC_ID-1]) == 0 or int(self.results[TC_ID-1]) == 2:
                HtmlData = HtmlData.replace("STATUS_TS", ConvertResult(0)) 
            TC_ID = TC_ID + 1
        # Fail rồi thì không còn STATUS_TS để pass nữa
        HtmlData = HtmlData.replace("STATUS_TS", ConvertResult(1))

        HTML_FILE = os.path.join(self.mTest.OUTPUT_DIR, self.mTest.TEST_NAME + ".html")
        with open(HTML_FILE, "w+") as file:
            file.write(HtmlData) 
            
        self.Result = StepStatus.SUCCEEDED
        self.LetEnd()