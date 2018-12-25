CodeGenerate.exe 命令参数

Namespace, //命名空间
ClassName, //类名
EnumName, //枚举名
InputFilePath, //输入的配置文件路径
OutputDirPath, //输出的代码存放路径
DictValueType, //字典值的类型
DictValueFormat, //字典值的格式化字符串,字符串格式 \"{0}\"


格式:
set inputFilePath=TestEnum.txt
set outputFilePath=tmp
set namespace=Config
set dictValueType=string
set dictValueFormat=\"{0}\"

CodeGenerator InputFilePath="%inputFilePath%" OutputDirPath="%outputFilePath%" Namespace="%namespace%" DictValueType="%dictValueType%" DictValueFormat="%dictValueFormat%"