using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Data;
using System.Data.OleDb;

namespace Excel2Sqlite3Prj
{
    public class ExcelOper
    {
        public const string TABLE_NAME = "TABLE_NAME";
        /// <summary>
        /// 是否仅导出 excel的第一个表格
        /// </summary>
        public const bool ONLY_EXPORT_FIRST_SHEET = true;
        public const string SQL_SELECT_ALL = @"select * from [{0}]";
        public const string CONN_STR = "Provider=Microsoft.ACE.OLEDB.12.0; Data Source={0};Extended Properties=\"Excel 12.0;HDR=NO;IMEX=1\"";
        public const string EXCEL_EXT_NAME = "xlsx";

        ArgInfo argInfo;

        public ExcelOper(ArgInfo argInfo)
        {
            this.argInfo = argInfo;
        }

        public DataSet ReadExcelToDataSet(string excelPath, string targetSheetName)
        {
            var extName = Path.GetExtension(excelPath);

            if (extName.ToLower().EndsWith(EXCEL_EXT_NAME))
            {
                var conn = new OleDbConnection(string.Format(CONN_STR, excelPath));
                conn.Open();

                var dataTable = conn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);

                var adapter = new OleDbDataAdapter();
                var dataset = new DataSet();

                //----- get target table
                foreach (DataRow row in dataTable.Rows)
                {
                    var sheetName = row[TABLE_NAME].ToString();
                    var exactSheetName = sheetName.Substring(0, sheetName.Length - 1);

                    if (IsDataSheet(sheetName) && exactSheetName == targetSheetName)
                    {
                        var selectCmd = string.Format(SQL_SELECT_ALL, sheetName);

                        adapter.SelectCommand = new OleDbCommand(selectCmd, conn);

                        var itemDataset = new DataSet();
                        adapter.Fill(itemDataset, exactSheetName); // sheet1$,remove $ character.

                        RemoveExcludeColumn(itemDataset.Tables[0]);

                        if (itemDataset.Tables[0].Rows.Count > 0)
                            dataset.Tables.Add(itemDataset.Tables[0].Copy());
                        itemDataset.Dispose();

                        if (ONLY_EXPORT_FIRST_SHEET)
                            break;
                    }
                }



                adapter.Dispose();
                conn.Close();
                return dataset;
            }
            return null;
        }

        void RemoveExcludeColumn(DataTable dt)
        {
            if (dt != null && !string.IsNullOrEmpty(argInfo.excludeColumns))
            {
                var colIds = argInfo.excludeColumns.Split(',');
                var colList = new List<DataColumn>();
                foreach (var item in colIds)
                {
                    colList.Add(dt.Columns[StringToIndex(item)]);
                }
                foreach (var item in colList)
                {
                    dt.Columns.Remove(item);
                }
            }
        }

        /// <summary>
        /// 将 列标(a,b)转为索引(1,2)
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public int StringToIndex(string str)
        {
            var chars = str.ToCharArray();
            var id = 0;

            for (int i = chars.Length - 1; i >= 0; i--)
            {
                var index = chars[i] - 'a';
                id += index;
                if (i != chars.Length - 1)
                {
                    id += (int)Math.Pow(26, i + 1) * (index + 1);
                }
            }
            return id;
        }

        bool IsDataSheet(string sheetName)
        {
            if (!string.IsNullOrEmpty(sheetName))
            {
                return sheetName.EndsWith("$");
            }
            return false;
        }
    }
}
