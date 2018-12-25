using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SQLite;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UtilityLib.Utilities.db;

namespace UtilityLib.Utilities
{
    public class DataSetOper
    {
        const string SELECT_NAME_FORM_SQLITE_MASTER = "select tbl_name from sqlite_master where tbl_name not like 'sqlite%'";
        public DataSet MainDataSet { get; private set; }
        public SQLiteDataAdapter Adapter { get; private set; }
        public void Close()
        {
            MainDataSet.Dispose();
            Adapter.Dispose();
        }
        /// <summary>
        /// 将db中所有的表导入到 dataset.
        /// 1 将第0列设置为主键.
        /// </summary>
        async public void FillMainDataSet(string connStr)
        {
            connStr = connStr.ToLower();
            if (string.IsNullOrEmpty(connStr) || !connStr.StartsWith("data source="))
            {
                throw new ArgumentException($"invalid connstr:{connStr}");
            }

            var conn = new SQLiteConnection(connStr);
            var cmd = conn.CreateCommand();
            cmd.CommandText = SELECT_NAME_FORM_SQLITE_MASTER;

            var selectCmd = conn.CreateCommand();
            Adapter = new SQLiteDataAdapter(selectCmd);

            var nameList = new List<string>();
            MainDataSet = new DataSet("MainDataSet");

            conn.Open();
            var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                nameList.Add(reader.GetString(0));
            }
            conn.Close();

            foreach (var tableName in nameList)
            {
                Adapter.SelectCommand.CommandText = $"select * from {tableName}";
                var t = MainDataSet.Tables.Add(tableName);
                var count = Adapter.Fill(t);
                //pk
                t.Constraints.Add("pk", t.Columns[0], true);
            }
            
            var cmdBuilder = new SQLiteCommandBuilder(Adapter);
            cmdBuilder.RefreshSchema();
        }

        public async Task<List<string>> GetTableNames(string connStr)
        {
            connStr = connStr.ToLower();
            if (string.IsNullOrEmpty(connStr) || !connStr.StartsWith("data source="))
            {
                throw new ArgumentException($"invalid connstr:{connStr}");
            }

            var conn = new SQLiteConnection(connStr);
            var cmd = conn.CreateCommand();
            cmd.CommandText = SELECT_NAME_FORM_SQLITE_MASTER;

            var selectCmd = conn.CreateCommand();
            var list = new List<string>();

            conn.Open();
            var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(reader.GetString(0));
            }
            conn.Close();
            return list;
        }

        public DataTable GetTable(string tableName)
        {
            if (!MainDataSet.Tables.Contains(tableName))
                throw new ApplicationException($"{tableName} not exists.");

            return MainDataSet.Tables[tableName];
        }

        public DataRow FindRow(DataTable table, params object[] keys)
        {
            if (keys.Length == 0)
                return null;

            if (table.Rows.Contains(keys))
                return table.Rows.Find(keys);
            return null;
        }

        public DataRow FindRow<T>(DataTable table,string columnName,T columnValue)
        {
            var q = from row in table.AsEnumerable()
            where row.Field<T>(columnName).Equals(columnValue)
                select row;
            return q.FirstOrDefault();
        }

        /// <summary>
        /// 通过columnName与columnValue找 datarow
        /// sqlite , int64,string
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="tableName"></param>
        /// <param name="columnName"></param>
        /// <param name="columnValue"></param>
        /// <returns></returns>
        public DataRow FindRow<T>(string tableName, string columnName, T columnValue)
        {
            return FindRow<T>(GetTable(tableName), columnName, columnValue);
        }

        /// <summary>
        /// 通过columnName,columnValue找到 datarow
        /// 在 dararow中,通过 targetColumnName找到 T
        /// </summary>
        /// <typeparam name="TColumn"></typeparam>
        /// <typeparam name="TTarget"></typeparam>
        /// <param name="tableName"></param>
        /// <param name="columnName"></param>
        /// <param name="columnValue"></param>
        /// <param name="targetColumnName"></param>
        /// <returns></returns>
        public TTarget FindScalar<TColumn,TTarget>(string tableName, string columnName,TColumn columnValue, string targetColumnName)
        {
            var row = FindRow<TColumn>(tableName, columnName, columnValue);
            if (row != null)
            {
                return row.Field<TTarget>(targetColumnName);
            }
            return default(TTarget);
        }

        public DataRow AddRow(DataTable table,params object[] values)
        {
            if (table.Columns.Count != values.Length)
                throw new InvalidOperationException($"args length != table:{table} columns length");

            return table.Rows.Add(values);
        }

        public DataRow AddRow(string tableName, params object[] values)
        {
            return AddRow(GetTable(tableName), values);
        }

        public int UpdateRow(DataTable table, Dictionary<int, object> valueDict, params object[] keys)
        {
            if (keys.Length == 0)
                return 0;

            var row = FindRow(table, keys);
            if (row != null)
            {
                foreach (var item in valueDict)
                {
                    row.SetField(item.Key, item.Value);
                }
                return 1;
            }
            return 0;
        }

        public int UpdateRow(string tableName, Dictionary<int, object> valueDict, params object[] keys)
        {
            return UpdateRow(GetTable(tableName), valueDict, keys);
        }

        public void DeleteRow(DataTable table, params object[] keys)
        {
            if (keys.Length == 0)
                return;

            var row = FindRow(table, keys);
            if (row != null)
                row.Delete();
        }

        public void DeleteRow(string tableName,params object[] keys)
        {
            DeleteRow(GetTable(tableName), keys);
        }

        public DataRow SelectRow(string tableName, params object[] keys)
        {
            return FindRow(GetTable(tableName), keys);
        }

        public void CommitTables()
        {
            foreach (DataTable table in MainDataSet.Tables)
            {
                CommitTable(table);
            }
            MainDataSet.AcceptChanges();
        }

        public int CommitTable(DataTable table)
        {
            if (table != null)
            {
                int c = Adapter.Update(table);
                table.AcceptChanges();
                return c;
            }
            return 0;
        }

        public int CommitDBSet<T>(DBSet<T> set)
            where T :ITable,new()
        {
            if(set != null)
            {
                return CommitTable(set.Table);
            }
            return 0;
        }

        /// <summary>
        /// 将当前row的column转为enum
        /// </summary>
        /// <typeparam name="TEnum">enum</typeparam>
        /// <param name="row"></param>
        /// <param name="callback"></param>
        public void Convert<TEnum>(DataRow row,Action<TEnum, DataColumn> callback)
            where TEnum : struct
        {
            if (row == null || callback == null)
                return;

            foreach (DataColumn item in row.Table.Columns)
            {
                TEnum k;
                if (Enum.TryParse(item.ColumnName, out k))
                {
                    callback(k,item);
                }
            }
        }

    }
}
