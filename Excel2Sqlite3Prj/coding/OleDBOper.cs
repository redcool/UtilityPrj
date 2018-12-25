using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Data;
using System.Data.OleDb;
using System.Data.SQLite;

namespace Excel2Sqlite3Prj
{
    public class OleDBOper
    {
        public const string SQLITE_CONN_STR = "Data Source={0}";
        public const string SQL_DROP_TABLE = "drop table if exists '{0}'";

        ArgInfo argInfo;
        SQLiteConnection sqliteConn;
        public OleDBOper(ArgInfo argInfo)
        {
            this.argInfo = argInfo;
        }

        void CheckConn(string dbPath)
        {
            if (!string.IsNullOrEmpty(dbPath))
            {
                if (sqliteConn == null)
                {
                    sqliteConn = new SQLiteConnection(string.Format(SQLITE_CONN_STR, dbPath));
                    sqliteConn.Open();
                }
            }
        }

        SQLiteCommand CreateCommand(string sql, params SQLiteParameter[] param)
        {
            CheckConn(argInfo.dbPath);
            var cmd = sqliteConn.CreateCommand();
            cmd.CommandText = sql;
            cmd.Parameters.AddRange(param);
            return cmd;
        }

        public int ExecuteNonQuery(string sql, params SQLiteParameter[] param)
        {
            var cmd = CreateCommand(sql, param);
            return cmd.ExecuteNonQuery();
        }

        public void BeginTransaction(params string[] sqls)
        {
            ExecuteNonQuery("PRAGMA foreign_keys = ON;");

            var curRowId = argInfo.dataRowNum;
            var tr = sqliteConn.BeginTransaction();
            try
            {
                foreach (var sql in sqls)
                {
                    curRowId++;
                    ExecuteNonQuery(sql);
                }
                tr.Commit();
            }
            catch (Exception e)
            {
                tr.Rollback();

                Console.WriteLine("\nerror:{0} \nline : {1} \n", e.Message, curRowId);
                Console.WriteLine(e);

                throw;
            }
        }

        public void Close()
        {
            if (sqliteConn != null)
                sqliteConn.Close();
        }
    }
}
