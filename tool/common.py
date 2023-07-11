# lib parser
import argparse
# lib logging
import logging
import subprocess
import os

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.DEBUG,
    handlers=[logging.StreamHandler()],
    datefmt='%Y-%m-%d %H:%M:%S',
    format='[%(asctime)s %(levelname)s] --> %(module)s: %(message)s'
)

class StepStatus:
    SUCCEEDED = 'SUCCEEDED'
    FAILED = 'FAILED'
    OK = "1"
    NOT_OK = "0"

class CommonStep:
    def __init__(self, Step, TestName):
        self.Step = Step.upper()
        self.TestName = TestName
        self.State = None
        self.Result = None

    def LetStart(self):
        self.State = "Start"
        logging.info(f"*************************************")
        logging.info(f" {self.State} {self.Step} {self.TestName}")
        logging.info(f"*************************************")

    def LetEnd(self):
        self.State = "End"
        logging.info(f"*************************************")
        logging.info(f" {self.State} {self.Step} {self.TestName} ===> [{self.Result}]")
        logging.info(f"*************************************\n")
    
    def RunCmd(Command: list):
        try:
            log = subprocess.run(Command, shell=True, capture_output=True, text=True)
            if type(log) == bytes:
                log = log.decode("utf-8")
            logging.info(log.args)
            if log.stdout:
                logging.info(log.stdout)
            if log.stderr:
                logging.info(log.stderr)
            if log.returncode:
                return False, str(log)
            else:
                return True, str(log)
        except subprocess.CalledProcessError as e:
            logging.error(e)
            return False, str(e)
    
# Create folder
def Make_Dir(path):
    if not os.path.isdir(path):
        os.makedirs(path,mode = 0o777,exist_ok= True)
        logging.info(f'Created Done {path}')

# binary data file
def ConvertDumpLog(dump_file, result_file):
    data = []
    with open(dump_file, 'rb') as f:
        byte = f.read(1)
        while byte:
            byte = f.read(1)
            if len(byte) > 0:
                ret = int(str(byte).replace('b\'\\', '0')[:-1], 16)
                data.append(str(ret)+'\n')
    with open(result_file, 'w') as f:
        f.writelines(data)

def ConvertResult(result):
    if int(result) == 0:
        return "FAIL"
    elif int(result) == 1:
        return "PASS"
    elif int(result) == 2:
        return "NOT_RUN"