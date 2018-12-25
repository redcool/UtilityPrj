/// Auto generated code,don't change manual!!
namespace CodeGenerator{
    using System;
    using System.Data;
    using System.Collections.Generic;
    using UtilityLib.Utilities.db;
    
    public static class MainTables{
        public static DataSet MainDataSet {get; private set;}
        public static DBSet<TableB> TableBs {get; private set;}
        public static DBSet<TableA> TableAs {get; private set;}
        
        public static void InitTables(DataSet ds){
            MainDataSet = ds;
            TableBs = new DBSet<TableB>(MainDataSet.Tables["TableB"]);
            TableAs = new DBSet<TableA>(MainDataSet.Tables["TableA"]);
        }
    }
}