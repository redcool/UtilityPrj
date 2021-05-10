
import math
import os
import sys
import glob
import gc
import threading

from pathlib import Path
from simplygon import simplygon_loader
from simplygon import Simplygon

def reductionFile(sg: Simplygon.ISimplygon,inputFilePath,outputFileDir):    
    outputFbxPath = outputFileDir +"/"+getFilename(inputFilePath)+".fbx"

    sgSceneImporter = sg.CreateSceneImporter()
    sgSceneImporter.SetImportFilePath(inputFilePath)
    if not sgSceneImporter.RunImport():
        raise Exception('Failed to load '+inputFilePath)
    sgScene = sgSceneImporter.GetScene()

    # Create the reduction processor. 
    sgReductionProcessor = sg.CreateReductionProcessor()

    sgReductionProcessor.SetScene( sgScene )

    sgReductionSettings = sgReductionProcessor.GetReductionSettings()

    # Set reduction target to triangle ratio with a ratio of 50%. 
    sgReductionSettings.SetReductionTargets( Simplygon.EStopCondition_All, True, False, False, False )
    sgReductionSettings.SetReductionTargetTriangleRatio( 0.5 )

    # Start the reduction process. 
    sgReductionProcessor.RunProcessing()


    sgSceneExporter = sg.CreateSceneExporter()
    sgSceneExporter.SetScene(sgScene)
    sgSceneExporter.SetExportFilePath(outputFbxPath)
    if not sgSceneExporter.RunExport():
        raise Exception('Failed to save '+outputFbxPath)


def getFilename(filePath):
    (fileDir,filename) = os.path.split(filePath)
    (file,ext) = filename.split(".")
    return file
    #return os.path.split(filePath)[1].split('.')[0]

def getFileExtname(filepath):
    (file,ext) = os.path.splitext(filepath)
    return ext[1:]


def getFilePaths(fileDir):
    names = os.listdir(fileDir)
    return [fileDir+"/" + x for x in names]

def getFilePathsFilterExtnames(filePaths,extNames):
    return [x for x in filePaths if getFileExtname(x) in extNames]


def runJob():
    curPath = os.getcwd()
    #print(curPath)

    inputDir = curPath+"/input"
    outputDir = curPath+"/ouput"

    inputFilePaths = getFilePaths(inputDir)
    inputFilePaths = getFilePathsFilterExtnames(inputFilePaths,["fbx,","obj"])

    sg = simplygon_loader.init_simplygon()
    if sg is None:
        exit(Simplygon.GetLastInitializationError())

    for path in inputFilePaths:
        reductionFile(sg,path,outputDir)

    sg = None
    gc.collect()

if __name__=="__main__":

    runJob()
