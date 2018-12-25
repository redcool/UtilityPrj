using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UtilityLib.Utilities.db
{
    /// <summary>
    /// Table vo 容器
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class DBSet<T>
        where T:ITable,new()
    {
        bool isChanged;
        HashSet<T> set = new HashSet<T>();
        T[] cachedArr;

        public DataTable Table { get; private set; }

        public DBSet(DataTable table)
        {
            this.Table = table;
            foreach (DataRow row in table.Rows)
            {
                var t = new T();
                t.DataRow = row;
                set.Add(t);
            }
        }

        /// <summary>
        /// 通过 主键(name为id的列)获取数据
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public T this[int id]
        {
            get {
                return Array.Find(ToArray(), (item) => (int)item.DataRow.Field<long>("id") == id);
            }
        }

        public T Find<Tcol>(string colName, Tcol value)
        {
            return Array.Find(ToArray(), (item) => item.DataRow.Field<Tcol>(colName).Equals(value));
        }

        public T[] FindAll<Tcol>(string colName, Tcol value)
        {
            return Array.FindAll(ToArray(), (item) => item.DataRow.Field<Tcol>(colName).Equals(value));
        }
        public T[] FindAll(Predicate<T> p)
        {
            return Array.FindAll(ToArray(), p);
        }

        public int Count
        {
            get { return set.Count; }
        }
        
        public void Add(T t)
        {
            isChanged = set.Add(t);
            if (isChanged)
            {
                Table.Rows.Add(t.DataRow);
                cachedArr = null;
            }
        }

        public void Remove(T t)
        {
            isChanged = set.Remove(t);
            if (isChanged)
            {
                t.DataRow.Delete();
                cachedArr = null;
            }
        }

        public T[] ToArray()
        {
            if (cachedArr == null)
                cachedArr = set.ToArray();
            return cachedArr;
        }

    }
}
