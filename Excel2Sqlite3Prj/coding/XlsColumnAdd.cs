using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.OleDb;
using System.Threading.Tasks;

using EXCEL = Microsoft.Office.Interop.Excel;

namespace Excel2Sqlite3Prj
{
    public class XlsColumnAdd
    {

        public void Start(params string[] param)
        {
            var path = param[0].Split('=')[1];
            Start(path);
        }
        public void Start(string excelPath)
        {
            EXCEL.Application app = new EXCEL.ApplicationClass();
            var book = app.Workbooks.Open(excelPath);

            EXCEL.Worksheet sheet = (EXCEL.Worksheet)book.Sheets[1];

            EXCEL.Range usedRange = sheet.UsedRange;
            int colCount = usedRange.Rows.Count;

            EXCEL.Range range = sheet.Range["a1"];
            range.EntireColumn.Insert(EXCEL.XlInsertShiftDirection.xlShiftToRight, EXCEL.XlInsertFormatOrigin.xlFormatFromRightOrBelow);
            range = sheet.Range["a1","a4"];

            // ------ header
            int i = 0;
            foreach (EXCEL.Range head in range)
            {
                switch (i)
                {
                    case 0:
                        head.Value = "序号"; break;
                    case 1: head.Value = "_index"; break;
                    case 2: head.Value = "INT_PK"; break;
                    case 3: head.Value = "F"; break;
                }
                i++;
            }
            // -------- data
            range = sheet.Range["a5","a"+colCount];
            i = 0;
            foreach (EXCEL.Range cell in range)
            {
                cell.Value2 = i++;
            }

            book.Save();
            book.Close();
            app.Quit();

        }

    }
}
