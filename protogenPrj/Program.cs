using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace protogenPrj
{
    /// <summary>
    /// protogenPrj command format:
    /// protogenPrj.exe -o:/outputs/TankProto.cs -ns:com.fanxing.protos -protoPath:/protos [-s]
    /// </summary>
    class Program
    {
        static void Main(string[] args)
        {
            new ProtoGen(args);

            Console.WriteLine("protogen finished.");
        }
    }
}
