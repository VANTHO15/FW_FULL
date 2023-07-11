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
import shutil
import os
from common import CommonStep,StepStatus,Make_Dir

class Generate(CommonStep):
    def __init__(self, mTest):
        self.Step = "generate"
        self.mTest = mTest
        super().__init__(self.Step, mTest.TEST_NAME)
        self.module = mTest.MODULE
        self.EbDir = mTest.EB_DIR
        self.Output = os.path.join(mTest.OUTPUT_DIR, "generate", self.mTest.GENERATOR)
        self.WorkSpaceEbDir = os.path.join(self.Output, "workspace")
        self.EbBatFile = os.path.join(self.EbDir, "bin", "tresos_cmd.bat")
    
    def Run(self):
        self.LetStart()

        self.ResultDir = os.path.join(self.Output, "result")
        Make_Dir(self.ResultDir)
        Make_Dir(self.Output)

        print("===========> Generating............................................................ !!!")
        ## copy cả folder template EB
        shutil.copytree(self.mTest.EB_TESTPROJECT, os.path.join(self.Output, "EbProject"), dirs_exist_ok=True)

        ## copy xdm files 
        for XdmFile in self.mTest.XDM_FILES:
            # Chia 2 phần, trước gạch chéo cuối cùng và sau gạch chéo cuối cùng
            head, XdmFileName = os.path.split(XdmFile) 
            # Copy xdm file bỏ vào EbProject
            XdmTemplateFile = os.path.normpath(XdmFile)
            Xdm_File = os.path.normpath(os.path.join(self.Output, "EbProject", "config", XdmFileName))
            with open(XdmTemplateFile,"r") as file:
                Data = file.read()
            with open(Xdm_File, "w+") as file:
                file.write(Data)
        
        #Delete
        if os.path.isdir(os.path.join(self.WorkSpaceEbDir, "EbProject")):
            Options = ['-data', self.WorkSpaceEbDir, 'deleteProject','-d', "EbProject"]
            Command = [self.EbBatFile] + Options
            CommonStep.RunCmd(Command)
        
        #import
        Options = [r'-data', self.WorkSpaceEbDir, r'importProject', '-c', os.path.join(self.Output, "EbProject")]
        Command = [self.EbBatFile] + Options
        CommonStep.RunCmd(Command)

        #generate
        Options = [r'-data', self.WorkSpaceEbDir, r'generate', "EbProject", '-o', self.Output]
        Command = [self.EbBatFile] + Options
        Result,Log = CommonStep.RunCmd(Command)

        if 'Errors "0"' in str(Log):
            with open(self.ResultDir + "/result.log", "w+") as ResultFile:
                ResultFile.write("1")   # OK
            self.Result = StepStatus.SUCCEEDED
        else:
            with open(self.ResultDir + "/result.log", "w+") as ResultFile:
                ResultFile.write("0")   # OK
            self.Result = StepStatus.FAILED

        self.LetEnd()