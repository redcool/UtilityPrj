using CodeGenerator;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UtilityLib.Utilities;
using UtilityLib.Utilities.db;

namespace Excel2Sqlite3Prj.TestCode
{
    public class TestGeneratedCode
    {

        DataSetOper dso;
        public TestGeneratedCode(string connStr = "data source=e:/tmp/a.db")
        {
            dso = new DataSetOper();
            dso.FillMainDataSet(connStr);

            MainTables.InitTables(dso.MainDataSet);
        }


        public void TestRead()
        {
            foreach (var item in MainTables.TableAs.ToArray())
            {
                Console.WriteLine(item);
            }

            foreach (var item in MainTables.TableBs.ToArray())
            {
                Console.WriteLine(item);
            }
        }

        public void TestWriteA()
        {
            MainTables.TableAs.Add(new TableA {
                id = 12,
                name = "abc123",
                values = 1.23f,
                tableBID = MainTables.TableBs[1],
            });
            dso.CommitDBSet(MainTables.TableAs);
        }

        public void TestWriteB()
        {
            var t1 = new TableB
            {
                id = 12,
                name = "中文abc123",
                values = 3.33f
            };
            MainTables.TableBs.Add(t1);
            dso.CommitDBSet(MainTables.TableBs);

            //MainTables.TableAs.Add(new TableA()
            //{
            //    id = 10,
            //    tableBID = t
            //});
            //dso.CommitTables();
        }

        public void TestUpdate()
        {
            MainTables.TableAs[1].name += "....";
            dso.CommitDBSet(MainTables.TableAs);

            MainTables.TableBs.ToArray()[0].name += "aaa";
            dso.CommitDBSet(MainTables.TableBs);
        }

        public void TestDeleteA()
        {

            MainTables.TableAs.Remove(MainTables.TableAs[1]);
            dso.CommitDBSet(MainTables.TableAs);
        }
        internal void TestDeleteB()
        {
            MainTables.TableBs.Remove(MainTables.TableBs[1]);
            dso.CommitDBSet(MainTables.TableBs);
        }

    }
}
