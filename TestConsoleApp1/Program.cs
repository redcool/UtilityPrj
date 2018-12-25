using CodeGenerator;
using Excel2Sqlite3Prj.coding.cmd;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using UtilityLib.Utilities;
using UtilityLib.Utilities.db;

namespace TestConsoleApp1
{

    class Program
    {
        static void Main(string[] args)
        {
            //UpdateConfigs();
            //TestDataSetOper(); 
            GenerateBat.RunBat(@"G:\Works\WuxiaSandbox\Docs\db\Excels");

            //var test = new Excel2Sqlite3Prj.TestCode.TestGeneratedCode();

            Console.WriteLine("done");
            Console.ReadKey();
        }

        static void TestDataSetOper()
        {
            var h = new DataSetOper();

            h.FillMainDataSet("e:/tmp/a.db");
            var t = h.MainDataSet.Tables[0];
            foreach (DataTable table in h.MainDataSet.Tables)
            {
                Console.WriteLine(table.TableName);
                foreach (DataColumn item in table.Columns)
                {
                    Console.WriteLine(item.Caption+":"+item.ColumnName);
                }

            }
        }

        static void UpdateAllEnum()
        {
            var path = @"G:\Works\WuxiaSandbox\Prj\Assets\SwordmenWorld";
            var paths = Directory.GetFiles(path, "*.cs", SearchOption.AllDirectories);
            var reg = new Regex(@"CharacterAttributeRange.([A-Z])(\w+)");
            foreach (var filePath in paths)
            {
                if (filePath.Contains("CodeGenerated"))
                    continue;

                var str = File.ReadAllText(filePath);
                if (reg.IsMatch(str))
                {
                    var newStr = reg.Replace(str, (m) =>
                    {
                        return "CharacterAttributeRange." + (char)(m.Groups[1].Value[0] + 32) + m.Groups[2].Value;
                    });

                    File.WriteAllText(filePath, newStr);

                    Console.WriteLine(filePath);
                    //break;
                }
            }
        }

    }
}
