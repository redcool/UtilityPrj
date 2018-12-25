using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UtilityLib.Utilities.db
{
    public interface ITable
    {
        DataRow DataRow { set; get; }
        int id { set; get; }
    }

}
