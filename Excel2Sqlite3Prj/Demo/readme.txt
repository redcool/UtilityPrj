这个工程是，将 excel文件导入到 sqlite的插件。

excel的格式,参见 demoA.xlsx

导表完毕将生成
	1 Table实体类.
	2 MainTables
工程启动时,需要调用MainTables.InitTables(DataSet)
之后,可以通过MainTables获取所有的Table了.

具体的命令参数
//要导出的excel路径
excelPath=../../demo.xlsx 
//字段名的行数
headerRowNum=1 
//数据行的行数
dataRowNum=4 
//字段类型 的行数
typeRowNum=2 
//导入的sqlite db文件路径
dbPath=e:/tmp/a.db 
//要导出的 excel表名
sheetName=Conf_Test
//导出时 排除的列名 分隔符为,
excludeColumns=b,c
//生成代码的存放路径
codeDirPath=Prj\Assets\SwordmenWorld\DataModel\CodeGenerated\Tables
//生成代码的命名空间
nsName=SwordmenWorld.Tables