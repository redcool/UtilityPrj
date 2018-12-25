using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UtilityLib.Utilities
{
    public static class StringBuilderEx
    {
        const string INDENT = "    ";
        public static StringBuilder AddIndent(this StringBuilder sb, int count)
        {
            for (int i = 0; i < count; i++)
            {
                sb.Append(INDENT);
            }
            return sb;
        }
    }
}
