using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UtilityLib.Utilities
{
    public static class ArgsParser
    {
        public static char parseArgsSeparator = '=';

        public static Dictionary<TEnum, TValue> ParseArgs<TEnum, TValue>(string wholeText,char seperator = '\n')
            where TEnum : struct
        {
            return ParseArgs<TEnum,TValue>(wholeText.Split(seperator));
        }

        /// <summary>
        /// 解析 key=value
        /// </summary>
        /// <typeparam name="TEnum"></typeparam>
        /// <typeparam name="TValue"></typeparam>
        /// <param name="lines"></param>
        /// <returns></returns>
        public static Dictionary<TEnum, TValue> ParseArgs<TEnum, TValue>(params string[] lines)
            where TEnum : struct
        {
            var dict = new Dictionary<TEnum, TValue>();
            foreach (var line in lines)
            {
                if (string.IsNullOrEmpty(line) || line.StartsWith("//"))
                    continue;

                var kv = line.Split(parseArgsSeparator);
                if (kv.Length == 2)
                {
                    var k = kv[0].Trim();
                    var v = kv[1].Trim();

                    TEnum enumKey;
                    if (Enum.TryParse(k, out enumKey))
                    {
                        if (dict.ContainsKey(enumKey))
                            dict.Remove(enumKey);

                        dict.Add(enumKey, (TValue)Convert.ChangeType(v, typeof(TValue)));
                    }
                }
                else
                {
                    throw new ApplicationException($"invalid arg : {line}");
                }
            }
            return dict;
        }

        public static RValue GetValue<TKey,TValue,RValue>(Dictionary<TKey,TValue> dict,TKey key, RValue defaultValue =default(RValue))
        {
            if (dict != null && dict.ContainsKey(key))
            {
                //return dict[key];
                return (RValue)Convert.ChangeType(dict[key], typeof(RValue));
            }
            return defaultValue;
        }

        /// <summary>
        /// 去除注释行.保留有效数据行
        /// </summary>
        /// <param name="lines"></param>
        /// <param name="commentChar"></param>
        /// <returns></returns>
        public static List<string> FilterLines(string[] lines,string commentStr = "//")
        {
            if (lines == null)
                return null;
            var list = new List<string>();
            foreach (var item in lines)
            {
                if(!string.IsNullOrEmpty(item) && !item.StartsWith(commentStr))
                    list.Add(item.Trim());
            }
            return list;
        }

        public static List<string> FilterLines(string allText,char lineSperator = '\n',string commentStr = "//")
        {
            if (string.IsNullOrEmpty(allText))
                return null;
            return FilterLines(allText.Split(lineSperator), commentStr);
        }
    }
}
