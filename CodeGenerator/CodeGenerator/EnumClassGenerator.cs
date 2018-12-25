using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UtilityLib.Utilities;

namespace CodeGenerator
{
    /// <summary>
    /// 将 key = value格式变成enum
    /// 1 key 存入 enum
    /// 2 value 存入 dict
    /// 不处理空行,注释行
    /// </summary>
    public class EnumClassGenerator
    {
        public enum ArgKey
        {
            Namespace, //命名空间
            ClassName, //类名
            EnumName, //枚举名
            InputFilePath, //输入的配置文件路径
            OutputDirPath, //输出的代码存放路径
            DictValueType, //字典值的类型
            DictValueFormat, //字典值的格式化字符串,字符串格式 \"{0}\"
        }

        Dictionary<ArgKey, string> argDict = new Dictionary<ArgKey, string>();
        string nsName = "Config";
        string className;
        string enumName;
        string inputFilePath;
        string outputDirPath;
        string dictValueType;
        string dictValueFormat;

        public EnumClassGenerator(params string[] args)
        {
            argDict = ArgsParser.ParseArgs<ArgKey,string>(args);

            inputFilePath = ArgsParser.GetValue(argDict, ArgKey.InputFilePath,"");
            outputDirPath = ArgsParser.GetValue(argDict, ArgKey.OutputDirPath,"");
            nsName = ArgsParser.GetValue(argDict, ArgKey.Namespace, nsName);
            enumName = ArgsParser.GetValue(argDict, ArgKey.EnumName, Path.GetFileNameWithoutExtension(inputFilePath));
            className = ArgsParser.GetValue(argDict, ArgKey.ClassName, $"{enumName}Class");
            dictValueType = ArgsParser.GetValue(argDict, ArgKey.DictValueType, "string");
            dictValueFormat = ArgsParser.GetValue(argDict,ArgKey.DictValueFormat,"\"{0}\"");

            Console.WriteLine();

            StartProcess(inputFilePath, outputDirPath);
        }

        void StartProcess(string inputPath, string outputDirPath)
        {
            if (!string.IsNullOrEmpty(inputPath) && !string.IsNullOrEmpty(outputDirPath))
            {
                var outputFilePath = string.Format($"{outputDirPath}/{className}.cs");

                var lines = File.ReadAllLines(inputPath);
                lines = ArgsParser.FilterLines(lines).ToArray();

                var classText = GetClassDeclare(lines);
                File.WriteAllText(outputFilePath, classText);
                Console.WriteLine(classText);
            }
        }

        string GetClassDeclare(string[] lines)
        {
            var nsNode = new HierarchyNode(0);
            nsNode.AppendLine("/// Auto generated code,don't change manual!!");
            nsNode.AppendLine("using System;");
            nsNode.AppendLine("using System.Collections.Generic;");
            nsNode.Append($"namespace {nsName} ").AppendLine("{");

            var enumNode = nsNode.NewNode();
            ProcessEnumDeclare(lines, enumName, enumNode);

            var classNode = nsNode.NewNode();
            classNode.Append($"public static class {className} ").AppendLine("{",false);

            var dictNode = classNode.NewNode();
            ProcessDict(lines, enumName, dictNode);

            classNode.AppendLine("}");
            nsNode.AppendLine("}");
            return nsNode.ToString();
        }

        void ProcessEnumDeclare(string[] lines, string enumName,HierarchyNode enumNode)
        {
            enumNode.Append($"public enum {enumName}").AppendLine(" {",false);

            var bodyNode = enumNode.NewNode();

            for (int i = 0, c = lines.Length; i < c; i++)
            {
                var k = lines[i];
                int num = -1;
                bool parseIntDone = false;
                if (k.Contains('='))
                {
                    var kv = k.Split('=');
                    k = kv[0].Trim();
                    var v = kv[1].Trim();

                    parseIntDone = int.TryParse(v, out num);
                }
                bodyNode.AppendLine(string.Format("{0}{1},", k, parseIntDone ? $"={num}" : ""));
            }
            enumNode.AppendLine("}");
        }


        void ProcessDict(string[] lines, string enumName,HierarchyNode dictNode)
        {
            const string dictName = "dict";
            dictNode.AppendLine($"public static Dictionary<{enumName},{dictValueType}> {dictName} = new Dictionary<{enumName},{dictValueType}>(){{");

            var bodyNode = dictNode.NewNode();
            for (int i = 0, c = lines.Length; i < c; i++)
            {
                var line = lines[i];
                if (line.Contains("="))
                {
                    var kv = line.Split('=');
                    var k = kv[0].Trim();
                    var v = string.Format(dictValueFormat, kv[1].Trim());

                    bodyNode.AppendLine($"{{{enumName}.{k},{v}}},");
                }
            }
            dictNode.AppendLine("};");
        }


    }

}