using System;
using System.Collections.Generic;
using System.Data;
using System.Dynamic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using UtilityLib.Utilities;

namespace Excel2Sqlite3Prj.GenerateCode
{
    class ClassInfo
    {
        public string name,type,comment;
        public bool isFk;
    }

    /// <summary>
    /// 生成 vo类.
    /// 实现 ITable
    /// 隐式转为DataRow
    /// </summary>
    public class TableClassGenerator
    {
        public string nsName;
        ArgInfo argInfo;

        Regex declareReg = new Regex(@"\w+");

        public TableClassGenerator(ArgInfo argInfo)
        {
            this.argInfo = argInfo;
        }
   
        public void ProcessTable(DataTable table)
        {
            var typeRow = table.Rows[argInfo.typeRowNum];
            var headerRow = table.Rows[argInfo.headerRowNum];
            var commentRow = table.Rows[argInfo.commentRowNum];
            var className = table.TableName;

            var varList = new List<ClassInfo>();
            for (int i = 0, c = table.Columns.Count; i < c; i++)
            {
                var typeText = typeRow.Field<string>(i);
                varList.Add(new ClassInfo()
                {
                    name = headerRow.Field<string>(i),
                    type = GetTypeDeclare(typeText),
                    isFk = typeText.StartsWith("int fk"),
                    comment = argInfo.commentRowNum != 0? commentRow.Field<string>(i) : null,
                });
            }

            var nsNode = new HierarchyNode(0);
            ProcessNsNode(nsNode);

            var classNode = nsNode.NewNode();
            classNode.AppendLine($"public class {className} : ITable {{");

            ProcessClassNode(classNode, varList, className);

            classNode.AppendLine("}");
            nsNode.AppendLine("}");

            if (!Directory.Exists(argInfo.codeDirPath))
            {
                Directory.CreateDirectory(argInfo.codeDirPath);
            }

            File.WriteAllText($"{argInfo.codeDirPath}/{className}.cs", nsNode.ToString());
            nsNode.Clear();

            // main table class.
            new MainTablesGenerator(argInfo).GenerateMainClass();
        }
        void ProcessNsNode(HierarchyNode nsNode)
        {
            nsNode.AppendLine("/// Auto generated code,don't change manual!!");

            nsNode.AppendLine($"namespace {argInfo.nsName}{{");
            var usingNode = nsNode.NewNode();
            usingNode.AppendLine("using System;");
            usingNode.AppendLine("using System.Data;");
            usingNode.AppendLine("using System.Collections.Generic;");
            usingNode.AppendLine("using UtilityLib.Utilities.db;");
            usingNode.AppendLine();
        }

        void ProcessClassNode(HierarchyNode classNode,List<ClassInfo> varList,string className)
        {
            //fields
            classNode.NewNode().AppendLine("public DataRow DataRow{set;get;}");
            //classNode.NewNode().AppendLine("public bool IsChanged{get;private set;}");
            //classNode.NewNode().AppendLine("public void AcceptChanges(){ DataRow.AcceptChanges(); }");
            ProcessFields(classNode, varList);
            //methods
            ProcessCtor(classNode,className);
            ProcessToStringMethod(classNode, varList);
        }

        void ProcessFields(HierarchyNode classNode, List<ClassInfo> varList)
        {
            foreach (var item in varList)
            {
                if (!string.IsNullOrEmpty(item.comment))
                {
                    var commentNode = classNode.NewNode();
                    commentNode.AppendLine("/// <summary>");
                    commentNode.AppendLine($"/* {item.comment} */");
                    commentNode.AppendLine("/// </summary>");
                }
                var setType = item.isFk ? "int" : item.type;
                var setValue = item.isFk ? "value.id" : "value";

                var fieldNode = classNode.NewNode();
                fieldNode.AppendLine($"public {item.type} {item.name} {{");
                fieldNode.NewNode().AppendLine($"get{{return {FieldStateText<string>(item.type,item.name)};}}");
                fieldNode.NewNode().AppendLine($"set{{DataRow.SetField<{setType}>(\"{item.name}\",{setValue}); }}");
                fieldNode.AppendLine("}");
            }
        }

        string FieldStateText<T>(string type,T id)
        {
            var idText = typeof(T).BaseType == typeof(ValueType) ? ""+ id : $"\"{id}\"";
            switch (type)
            {
                case "int":
                    return $"(int)DataRow.Field<long>({idText})";
                case "float":
                    return $"(float)DataRow.Field<double>({idText})";
                case "string":
                    return $"DataRow.Field<string>({idText})";
                default: //reference.
                    //return $"new {type}({MainTablesGenerator.className}.{MainTablesGenerator.mainDatasetName}.Tables[\"{type}\"].Rows.Find((int)DataRow.Field<long>({idText})))";
                    return $"MainTables.{type}s[(int)DataRow.Field<long>({idText})]";
            }
        }

        void ProcessCtor(HierarchyNode classNode,string className)
        {
            var ctorNode = classNode.NewNode();
            ctorNode.AppendLine($"public {className}(){{");
            ctorNode.NewNode().AppendLine($"DataRow = {MainTablesGenerator.className}.{MainTablesGenerator.mainDatasetName}.Tables[\"{className}\"].NewRow();");
            ctorNode.AppendLine("}");

            var ctor1Node = classNode.NewNode();
            ctor1Node.AppendLine($"public {className}(DataRow row){{");
            ctor1Node.NewNode().AppendLine("DataRow = row;");
            ctor1Node.AppendLine("}");
        }

        void ProcessToStringMethod(HierarchyNode classNode,List<ClassInfo> varList)
        {
            var toStringNode = classNode.NewNode();
            toStringNode.AppendLine("public override string ToString(){");
            var node = toStringNode.NewNode();
            node.Append("return $\"{{");
            foreach (var item in varList)
            {
                node.Append($"{item.name}:{{{item.name}}},",false);
            }
            node.AppendLine("}}\";",false);
            toStringNode.AppendLine("}");
        }

        string GetTypeDeclare(string excelType)
        {
            var ms = declareReg.Matches(excelType);
            if (ms.Count == 4) //type fk class field
            {
                return ms[2].Value;
            }
            switch (ms[0].Value.ToLower())
            {
                case "byte":
                case "short":
                case "int": return "int";
                case "float":
                case "double": return "float";
                case "text": return "string";
            }
            throw new InvalidCastException($"{ms[0].Value} can't handle");
        }
    }
}
