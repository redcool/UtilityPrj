/// Auto generated code,don't change manual!!
namespace CodeGenerator{
    using System;
    using System.Data;
    using System.Collections.Generic;
    using UtilityLib.Utilities.db;
    
    public class TableA : ITable {
        public DataRow DataRow{set;get;}
        /// <summary>
        /* 1 */
        /// </summary>
        public int id {
            get{return (int)DataRow.Field<long>("id");}
            set{DataRow.SetField<int>("id",value); }
        }
        /// <summary>
        /* bc */
        /// </summary>
        public string name {
            get{return DataRow.Field<string>("name");}
            set{DataRow.SetField<string>("name",value); }
        }
        /// <summary>
        /* 1 */
        /// </summary>
        public TableB tableBID {
            get{return MainTables.TableBs[(int)DataRow.Field<long>("tableBID")];}
            set{DataRow.SetField<int>("tableBID",value.id); }
        }
        /// <summary>
        /* 1.1 */
        /// </summary>
        public float values {
            get{return (float)DataRow.Field<double>("values");}
            set{DataRow.SetField<float>("values",value); }
        }
        public TableA(){
            DataRow = MainTables.MainDataSet.Tables["TableA"].NewRow();
        }
        public TableA(DataRow row){
            DataRow = row;
        }
        public override string ToString(){
            return $"{{id:{id},name:{name},tableBID:{tableBID},values:{values},}}";
        }
    }
}
