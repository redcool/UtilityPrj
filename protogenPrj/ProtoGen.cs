using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Diagnostics;

namespace protogenPrj
{
    /// <summary>
    /// 编译*.proto文件.
    /// 当前目录下,须有 proto_net的目录.
    /// </summary>
    public class ProtoGen
    {
        const string ARG_NS = "-ns:";
        const string ARG_O = "-o:";
        const string ARG_PROTOS_PATH = "-protosPath:";
        const string ARG_PROTOGEN_PATH = "-protogenPath:";

        string protogenPath;
        string outputPath;
        string protosPath;

        string globalNamespace = "Com.Test";

        public ProtoGen(string[] args)
        {
            ParseArgs(args);

            string allArgs = GetProtosArgs(args);
            //切换工作目录.
            Environment.CurrentDirectory = protosPath;
            //开始 新进程.
            var startInfo = new ProcessStartInfo(protogenPath, allArgs);
            startInfo.RedirectStandardOutput = true;
            startInfo.UseShellExecute = false;

            Process p = Process.Start(startInfo);
            using (StreamReader sr = p.StandardOutput)
            {
                Console.WriteLine(sr.ReadToEnd());
            }
        }

        /// <summary>
        /// 得到这样的格式: -i:"D:\Works\TankPrj\Prj\proto_tools\protogenPrj\protogenPrj\protogenPrj\bin\Debug / protos\Account.proto" -i:"D:\Works\TankPrj\Prj\proto_tools\protogenPrj\protogenPrj\protogenPrj\bin\Debug / protos\Battle.proto"
        /// </summary>
        /// <returns></returns>
        public string GetProtosPath()
        {
            StringBuilder sb = new StringBuilder();
            string[] protos = Directory.GetFiles(protosPath);
            foreach (var item in protos)
            {
                if (item.EndsWith(".proto"))
                {
                    sb.Append("-i:").Append("\"").Append(item).Append("\" ");
                }
            }
            return sb.ToString();
        }

        string GetProtosArgs(string[] args)
        {
            //----- get protogen args
            string inputs = GetProtosPath();
            //得到这样的格式: -o:"D:\Works\TankPrj\Prj\proto_tools\protogenPrj\protogenPrj\protogenPrj\bin\Debug/outputs/Output.cs"
            string outputs = string.Format("{0}\"{1}\" ", ARG_O, outputPath);
            return string.Format(" {0}{1}{2}{3}", inputs, outputs, ARG_NS, globalNamespace);
        }

        void ParseArgs(string[] args)
        {
            foreach (var item in args)
            {
                if (item.StartsWith(ARG_NS))
                {
                    globalNamespace = item.Substring(ARG_NS.Length); // -ns:com.abc
                }
                else if (item.StartsWith(ARG_O))
                {
                    outputPath = item.Substring(ARG_O.Length); // -o:d:/outputs/Proto.cs
                }
                else if (item.StartsWith(ARG_PROTOS_PATH))
                {
                    protosPath = item.Substring(ARG_PROTOS_PATH.Length); //-protoPath:/protos
                }
                else if (item.StartsWith(ARG_PROTOGEN_PATH))
                {
                    protogenPath = item.Substring(ARG_PROTOGEN_PATH.Length);
                }
            }
        }
    }
}
