using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;

namespace Excel2Sqlite3Prj.coding.cmd
{
    public static class GenerateBat
    {

        const string templateText = @"@echo off
set dbPath=Prj\Assets\StreamingAssets\wu_cn.db
set excelPath=Docs\db\Excels{9}\{0}
set sheetName={1}
set headerRowNum={2}
set dataRowNum={3}
set typeRowNum={4}
set excludeColumns={5}
set codeDirPath={6}
set nsName={7}
set mainDataSetPath={8}
cd ..\..\..\{10}
ExternalTools\Excel2Sqlite3\Excel2Sqlite3Prj excelPath=%excelPath% headerRowNum=%headerRowNum% dataRowNum=%dataRowNum% typeRowNum=%typeRowNum% dbPath=%dbPath% sheetName=%sheetName% excludeColumns=%excludeColumns% codeDirPath=%codeDirPath% nsName=%nsName% mainDataSetPath=%mainDataSetPath%";

        public static void UpdateExcels(string dir,string pattern="*.bat")
        {

            var files = Directory.GetFiles(dir, pattern, SearchOption.AllDirectories);
            foreach (var file in files)
            {
                Console.WriteLine(file);
                var text = File.ReadAllText(file);
                var dirName = Regex.Match(text,@"Excels[/\\](\w+)[/\\]");

                var excelName = Regex.Match(text, @"\w+.xlsx");
                //Console.WriteLine(excelName.Value);

                var sheetName = Regex.Match(text, @"sheetName=(\w+)");
                //Console.WriteLine(sheetName.Groups[1].Value);

                var headerRowNum = Regex.Match(text, @"headerRowNum=(\d)");
                //Console.WriteLine(headerRowNum.Groups[1].Value);

                var dataRowNum = Regex.Match(text, @"dataRowNum=(\d)");
                //Console.WriteLine(dataRowNum.Groups[1].Value);

                var typeRowNum = Regex.Match(text, @"typeRowNum=(\d)");
                //Console.WriteLine(dataRowNum.Groups[1].Value);

                var excludeColumns = Regex.Match(text, @"excludeColumns=(((\w+),?)+)");
                //Console.WriteLine(excludeColumns.Groups[1].Value);

                var codeDirPath = @"Prj\Assets\SwordmenWorld\DataModel\CodeGenerated\Tables";
                var nsName = @"SwordmenWorld.Tables";
                var mainDataSetPath = @"SwordmenWorld.DBAccess.Instance.ConfigDataSet";

                File.WriteAllText(file, string.Format(templateText,
                    excelName.Value,
                    sheetName.Groups[1].Value,
                    headerRowNum.Groups[1].Value,
                    dataRowNum.Groups[1].Value,
                    typeRowNum.Groups[1].Value,
                    excludeColumns.Groups[1].Value,
                    codeDirPath,
                    nsName,
                    mainDataSetPath,
                    dirName.Success?$"\\{dirName.Groups[1].Value}":"",
                    dirName.Success?"..\\":""
                    ));
                break;
            }
        }

        async public static void RunBat(string dir,string pattern="*.bat")
        {
            var files = Directory.GetFiles(dir, pattern, SearchOption.AllDirectories);
            foreach (var item in files)
            {
                Console.WriteLine(item);
                Environment.CurrentDirectory = Path.GetDirectoryName(item);

                await Task.Run(() => {
                    var p = Process.Start(item);
                        Thread.Sleep(500);
                    p.Close();
                });

   
            }
        }
    }
}
