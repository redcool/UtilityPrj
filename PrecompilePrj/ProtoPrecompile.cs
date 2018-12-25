using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.IO;

namespace PrecompilePrj
{
    public class ProtoPrecompile
    {
        string precompilePath = "./proto_net/Precompile/";
        const string FILE_NAME = "precompile.exe";
        const string ARG_O = "-o:";
        const string ARG_T = "-t:";
        const string ARG_DLL = ".dll";
        const string ARG_PRECOMPILE_PATH = "-precompilePath:";
        readonly string originalPath;
        string GetArgs(string[] args)
        {
            StringBuilder sb = new StringBuilder();
            foreach (var item in args)
            {
                if (item.EndsWith(ARG_DLL) && !item.StartsWith(ARG_O))
                    sb.AppendFormat(" {0}\\{1}", originalPath, item);
                else if (item.StartsWith(ARG_O))
                {
                    sb.AppendFormat(" {0}{1}\\{2}", ARG_O, originalPath, item.Substring(ARG_O.Length));
                }
                else
                {
                    sb.AppendFormat(" {0}", item);
                }
            }
            return sb.ToString();
        }

        public ProtoPrecompile(params string[] args)
        {
            originalPath = Environment.CurrentDirectory;

            var argsStr = GetArgs(args);
            Console.WriteLine(argsStr);

            Environment.CurrentDirectory = Environment.CurrentDirectory + precompilePath;

            //Console.WriteLine(Environment.CurrentDirectory);

            var startInfo = new ProcessStartInfo(FILE_NAME, argsStr);
            startInfo.RedirectStandardOutput = true;
            startInfo.UseShellExecute = false;

            Process p = Process.Start(startInfo);
            StreamReader sr = p.StandardOutput;

            Console.WriteLine(".");
            Console.WriteLine(sr.ReadToEnd());
        }

    }
}
