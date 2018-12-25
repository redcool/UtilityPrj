using System;
using System.Data;
using System.Threading.Tasks;
using UtilityLib.Utilities;

namespace Excel2Sqlite3Prj
{
    public class Program
    {
        static void Main(string[] args)
        {
            new Excel2Sqlite().Export(args);
            

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("exported done.");

            Console.ReadKey();
        }



    }
}
