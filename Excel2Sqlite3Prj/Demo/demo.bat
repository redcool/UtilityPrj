@echo off
set dbPath=Prj\Assets\StreamingAssets\wu_cn.db
set excelPath=Docs\db\Excels\GamePlay.xlsx
set sheetName=GamePlay
set headerRowNum=1
set dataRowNum=4
set typeRowNum=2
set commentRowNum=0
set excludeColumns=e
set codeDirPath=Prj\Assets\SwordmenWorld\DataModel\CodeGenerated\Tables
set nsName=SwordmenWorld.Tables
cd ..\..\..\
ExternalTools\Excel2Sqlite3\Excel2Sqlite3Prj excelPath=%excelPath% headerRowNum=%headerRowNum% dataRowNum=%dataRowNum%  commentRowNum=%commentRowNum% typeRowNum=%typeRowNum% dbPath=%dbPath% sheetName=%sheetName% excludeColumns=%excludeColumns% codeDirPath=%codeDirPath% nsName=%nsName%
