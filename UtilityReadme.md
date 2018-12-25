Utility工程是外部工程.

=======================================
COnfigCodeGenerator . 配置文件代码生成器.
=======================================
txt文件形式如:

key = value



=======================================
Excel2SqlitePrj.
=======================================
功能:
	1 excel 导入 sqlite3
	2 生成table类,
		通过MainTable来调用.
		通过DataReader来逐个读取
	
注意事项:
需要先安装AccessDatabaseEngine
1 excel2Sqlite运行时,找不到sqlite.dll.
  将UtilityPrj\Excel2Sqlite3Prj\dll\x64 拷贝到excel2Sqlite.exe目录.

在unity中需要导入 sqlite3.unitypackage.
里面包括了必须的dll与几个工具类.

=======================================
UtilityLib
=======================================
	/UnityScripts : 常用的unity工具及脚本
	/Utilities : 其他工具类.
	