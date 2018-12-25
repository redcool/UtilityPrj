using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeGenerator
{
    class Program
    {
        static void Main(string[] args)
        {
            new EnumClassGenerator(args);

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("generate done.");
            Console.ReadKey();
        }
    }
}
