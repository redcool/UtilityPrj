using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.Data;
using UtilityLib.Utilities;
using Excel2Sqlite3Prj.GenerateCode;

namespace Excel2Sqlite3Prj
{

    public class ArgInfo
    {
        public string excelPath;
        public string sheetName;
        public string dbPath;
        public string excludeColumns;
        public string codeDirPath;
        public string nsName;
        public int headerRowNum;
        public int dataRowNum;
        public int typeRowNum;
        public int commentRowNum;
    }

    enum ArgKey
    {
        dbPath,
        excelPath,
        sheetName,
        headerRowNum,
        dataRowNum,
        typeRowNum,
        commentRowNum,
        excludeColumns,
        codeDirPath,
        nsName,
    }
    enum DDLKey
    {
        pk, fk, auto
    }

    /// <summary>
    /// 将xlsx 导入到 sqlite3.
    /// 
    /// excelPath=D:\Works\TankPrj\Prj\TankWar1\Docs\ConfTable\public\conf_rare_performance_public.xlsx 
    /// headerRowNum=1                          //名称行id
    /// typeRowNum=2                            //类型行id
    /// commentRowNum                           //注释行id
    /// dataRowNum=4                            //数据行id
    /// sheetName=conf_rare_performance         //要导出数据的表名
    /// dbPath=d:/tmp/a.db                      //要导入到的sqlite db文件路径
    /// excludeColumns=b,c                      //导入数据时剔除这些列.
    /// codeDirPath=d:/tmp                      //生成cs代码放置路径
    /// nsName=CodeGenerator                    //生成cs代码的命名空间
    /// </summary>
    public class Excel2Sqlite
    {
        const string INTRODUCTION =
        @"******************** 
            Usage: 
            Excel2Sqlite3Prj.exe
            dbPath=d:/tmp/a.db
            excelPath=d:/tmp/a.xlsx
            headerRowNum=0
            typeRowNum=1
            dataRowNum=2
            commentRowNum=3
            sheetName=Sheet1
            excludeColumns=b,c
            codeDirPath=d:/tmp
            nsName=CodeGenerator
        ********************";

        ArgInfo argInfo = new ArgInfo();
        OleDBOper dbOper;
        ExcelOper excelOper;
        /// <summary>
        /// excelPath=xx
        /// dbPath=xx
        /// headerRowNum=1
        /// dataRowNum = 3
        /// </summary>
        /// <param name="args"></param>
        public void Export(params string[] args)
        {
            Console.WriteLine(INTRODUCTION);

            if (args.Length < 2)
                return;

            var dict = ArgsParser.ParseArgs<ArgKey,string>(args);
            SetupArgInfo(dict);

            dbOper = new OleDBOper(argInfo);
            excelOper = new ExcelOper(argInfo);

            Export(argInfo);
        }

        void SetupArgInfo(Dictionary<ArgKey,string> dict)
        {
            if (dict != null)
            {
                argInfo.dbPath = GetAbsPath(ArgsParser.GetValue(dict, ArgKey.dbPath,""));
                argInfo.excelPath = GetAbsPath(ArgsParser.GetValue(dict, ArgKey.excelPath,""));

                argInfo.sheetName = ArgsParser.GetValue(dict, ArgKey.sheetName,"");
                argInfo.headerRowNum = ArgsParser.GetValue(dict, ArgKey.headerRowNum,-1);
                argInfo.dataRowNum = ArgsParser.GetValue(dict, ArgKey.dataRowNum, -1);
                argInfo.typeRowNum = ArgsParser.GetValue(dict, ArgKey.typeRowNum,-1);
                argInfo.commentRowNum = ArgsParser.GetValue(dict, ArgKey.commentRowNum, -1);

                argInfo.excludeColumns = ArgsParser.GetValue(dict, ArgKey.excludeColumns,"");
                argInfo.codeDirPath = ArgsParser.GetValue(dict, ArgKey.codeDirPath, "");
                argInfo.nsName = ArgsParser.GetValue(dict, ArgKey.nsName, "");

                //excel的id从1开始.
                argInfo.headerRowNum -= 1;
                argInfo.dataRowNum -= 1;
                argInfo.typeRowNum -= 1;
            }
        }

        string GetAbsPath(string path)
        {
            if (path.Contains(":/"))
            {
                return path;
            }
            return string.Format("{0}/{1}", Environment.CurrentDirectory, path);
        }

        public void Export(ArgInfo argInfo)
        {
            if (string.IsNullOrEmpty(argInfo.sheetName))
            {
                Console.WriteLine(string.Format("sheetName not specified!"));
                return;
            }
            if (!File.Exists(argInfo.excelPath) || !File.Exists(argInfo.dbPath))
            {
                Console.WriteLine(string.Format("File not exists!\n dbPath:{0},\n excelPath:{1}", argInfo.dbPath, argInfo.excelPath));
                return;
            }

            var ds = excelOper.ReadExcelToDataSet(argInfo.excelPath, argInfo.sheetName);
            if (ds != null)
            {
                HandleTables(ds);
                ds.Dispose();
            }
        }

        void HandleTables(DataSet dataset)
        {
            if (dataset.Tables.Count == 0)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                throw new InvalidProgramException($"{argInfo.sheetName} not found.");
            }
            //----- handle dataset
            foreach (DataTable table in dataset.Tables)
            {
                try
                {
                    Console.WriteLine(string.Format("{0} export start", table.TableName));
                    HandleCreateTable(table);
                    var count = HandleTablelData(table);
                    Console.WriteLine(string.Format("table: {0} ,{1} rows exported.", table.TableName,count));

                    //generate class
                    new TableClassGenerator(argInfo).ProcessTable(table);
                }
                catch(Exception e)
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine(e);
                    break;
                }
            }
            dbOper.Close();
        }

        void HandleCreateTable(DataTable table)
        {
            dbOper.ExecuteNonQuery(string.Format(OleDBOper.SQL_DROP_TABLE, table.TableName));
            var createTableSql = GetTableDefineSQL(table);
            Console.WriteLine(createTableSql);

            dbOper.ExecuteNonQuery(createTableSql);
        }

        int HandleTablelData(DataTable table)
        {
            var rowCount = table.Rows.Count;
            var colCount = table.Columns.Count;

            var list = new List<string>();
            var sqlBuilder = new StringBuilder();
            for (int i = argInfo.dataRowNum; i < rowCount; i++)
            {
                sqlBuilder.Clear();
                var row = table.Rows[i];

                var rowSqlSb = new StringBuilder();
                rowSqlSb.AppendFormat("insert into {0} values(", table.TableName);
                for (int j = 0; j < colCount; j++)
                {
                    var cell = row[j].ToString();
                    if (!string.IsNullOrEmpty(cell))
                    {
                        if (IsNumeric(cell))
                            rowSqlSb.AppendFormat("{0},", cell);
                        else
                            rowSqlSb.AppendFormat("'{0}',", cell);
                    }
                    else //found null!!
                    {
                        rowSqlSb.Clear();
                        throw new Exception(string.Format("Null found. row: {0},col: {1}", i + argInfo.dataRowNum, j));
                    }
                }
                if (rowSqlSb.Length > 0 && rowSqlSb[rowSqlSb.Length - 1] == ',')
                {
                    rowSqlSb.Remove(rowSqlSb.Length - 1, 1);
                    rowSqlSb.Append(");");
                    sqlBuilder.Append(rowSqlSb.ToString());

                    list.Add(sqlBuilder.ToString());
                }
            }

            dbOper.BeginTransaction(list.ToArray());
            return list.Count;
        }


        bool IsNumeric(string str)
        {
            if (!str.Contains(","))
            {
                int cellInt = 0;
                float cellFloat = 0;
                if (int.TryParse(str, out cellInt))
                    return true;
                if (float.TryParse(str, out cellFloat))
                    return true;
            }

            return false;
        }
        string GetTableDefineSQL(DataTable table)
        {
            var colCount = table.Columns.Count;
            var headerRow = table.Rows[argInfo.headerRowNum];
            var typeRow = table.Rows[argInfo.typeRowNum];

            StringBuilder contentSB = new StringBuilder();
            StringBuilder constraintSB = new StringBuilder();

            contentSB.AppendFormat("create table '{0}' (", table.TableName);
            for (int i = 0; i < colCount; i++)
            {
                var colName = headerRow[i].ToString();
                var fullColType = typeRow[i].ToString();
                if (!string.IsNullOrEmpty(colName) && !string.IsNullOrEmpty(fullColType))
                {
                    HandleColumnAndType(colName, fullColType, contentSB, constraintSB);
                    contentSB.Append(",");
                }
            }
            //remove last character ','
            if (constraintSB.Length == 0)
                contentSB.Remove(contentSB.Length - 1, 1);
            else
                constraintSB.Remove(constraintSB.Length - 1, 1);

            contentSB.Append(constraintSB);
            contentSB.Append(")");
            return contentSB.ToString();
        }

        string GetSqliteDataType(string colType)
        {
            switch (colType.ToLower())
            {
                case "byte":
                case "short":
                case "int": return "integer";
                case "float":
                case "double": return "real";
                case "string": return "text";
            }
            return colType;
        }

        /// <summary>
        /* 
        CREATE TABLE "Conf_Test" (
        "id"  integer PRIMARY KEY AUTOINCREMENT,
        "uid"  text,
        "prop_id"  integer,
        FOREIGN KEY("prop_id") REFERENCES "Prop_id" ("id")
        );
        */
        /// </summary>
        /// <param name="colName"></param>
        /// <param name="originalColType"></param>
        /// <param name="colSB"></param>
        /// <param name="constraintSB"></param>
        void HandleColumnAndType(string colName, string originalColType, StringBuilder contentSB, StringBuilder constraintSB)
        {
            contentSB.AppendFormat("'{0}'", colName);
            var colTypeLower = originalColType.ToLower();
            var matchs = Regex.Matches(colTypeLower, @"\w+");

            var sqliteType = GetSqliteDataType(matchs[0].ToString());
            contentSB.AppendFormat(" {0}", sqliteType);

            if (matchs.Count > 1)
            {
                DDLKey ddlKey;
                if (!Enum.TryParse(matchs[1].ToString(), out ddlKey))
                {
                    Console.WriteLine("convert to ddlKey fail : {0}", matchs[1]);
                    return;
                }

                switch (ddlKey)
                {
                    case DDLKey.pk: //type pk
                        contentSB.Append(" primary key autoincrement ");
                        break;
                    case DDLKey.fk: //type fk tableName id
                        if (matchs.Count == 4)
                            constraintSB.AppendFormat(@"foreign key('{0}') references '{1}' ('{2}'),", colName, matchs[2], matchs[3]);
                        break;
                }
            }
        }

    }
}
