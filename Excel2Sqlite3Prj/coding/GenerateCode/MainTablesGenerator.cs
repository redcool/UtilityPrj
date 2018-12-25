using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UtilityLib.Utilities;
using UtilityLib.Utilities.db;

namespace Excel2Sqlite3Prj.GenerateCode
{
    /// <summary>
    /// 生成 MainTables class
    /// MainTables用来操作 所有的 Table类
    /// </summary>
    public class MainTablesGenerator
    {
        public const string className = "MainTables";
        public const string mainDatasetName = "MainDataSet";

        ArgInfo argInfo;
        public MainTablesGenerator(ArgInfo info)
        {
            argInfo = info;
        }

        async public void GenerateMainClass()
        {
            var dsOper = new DataSetOper();
            var nameList = await dsOper.GetTableNames($"data source={argInfo.dbPath}");

            var nsNode = new HierarchyNode(0);
            nsNode.AppendLine("/// Auto generated code,don't change manual!!");
            //ns node
            nsNode.AppendLine($"namespace {argInfo.nsName}{{");
            var usingNode = nsNode.NewNode();
            usingNode.AppendLine("using System;");
            usingNode.AppendLine("using System.Data;");
            usingNode.AppendLine("using System.Collections.Generic;");
            usingNode.AppendLine("using UtilityLib.Utilities.db;");
            usingNode.AppendLine();
            //class
            var classNode = nsNode.NewNode();
            classNode.AppendLine($"public static class {className}{{");
            classNode.NewNode().AppendLine($"public static DataSet {mainDatasetName} {{get; private set;}}");
            classNode.NewNode().AppendLine($"public static event Action OnDataLoaded;");
            foreach (var tableName in nameList)
            {
                var fieldNode = classNode.NewNode();
                fieldNode.AppendLine($"public static DBSet<{tableName}> {tableName}s {{get; private set;}}");
            }
            classNode.NewNode().AppendLine();

            // InitTables method;
            SetupInitTables(nameList, classNode);

            classNode.AppendLine("}");
            nsNode.Append("}");

            File.WriteAllText(argInfo.codeDirPath + $"/{className}.cs", nsNode.ToString());
            nsNode.Clear();
        }

        void SetupInitTables(List<string> nameList, HierarchyNode classNode)
        {
            var methodNode = classNode.NewNode();
            methodNode.AppendLine("public static void InitTables(DataSet ds){");
            methodNode.NewNode().AppendLine($"{mainDatasetName} = ds;");
            foreach (var tableName in nameList)
            {
                var stateNode = methodNode.NewNode();
                stateNode.AppendLine($"{tableName}s = new DBSet<{tableName}>({mainDatasetName}.Tables[\"{tableName}\"]);");
            }
            methodNode.NewNode().AppendLine("OnDataLoaded?.Invoke();");
            methodNode.AppendLine("}");
        }
    }
}
