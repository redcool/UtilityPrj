#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace PowerVFX
{

    /// <summary>
    /// key=value,ÅäÖÃÎÄ¼þ²Ù×÷
    /// </summary>
    public static class ConfigTool
    {
        static Dictionary<string, string> propNameValuedict = new Dictionary<string, string>();

        public static void Reset()
        {
            propNameValuedict.Clear();
        }

        static string FindI18NPath(string configPath)
        {
            var pathDir = Path.GetDirectoryName(configPath);
            var filePath = "";
            var findCount = 0;
            while (!pathDir.EndsWith("Assets"))
            {
                filePath = pathDir + "/i18n.txt";
                pathDir = Path.GetDirectoryName(pathDir);
                if (File.Exists(filePath) || ++findCount > 10)
                    break;
            }
            return filePath;
        }

        public static void ReadConfig(string configPath)
        {
            if (propNameValuedict.Count > 0)
                return;

            var splitRegex = new Regex(@"\s*=\s*");
            var filePath = FindI18NPath(configPath);

            if (!string.IsNullOrEmpty(filePath))
            {
                var lines = File.ReadAllLines(filePath);
                foreach (var lineStr in lines)
                {
                    var line = lineStr.Trim();
                    if (string.IsNullOrEmpty(line) || line.StartsWith("//"))
                        continue;

                    var kv = splitRegex.Split(line);
                    if (kv.Length > 1)
                        propNameValuedict[kv[0]] = kv[1];
                }
            }

        }

        public static void ReadConfig(Shader shader)
        {
            var path = AssetDatabase.GetAssetPath(shader);
            ReadConfig(path);
        }

        public static Dictionary<string, MaterialProperty> CacheProperties(MaterialProperty[] properties)
        {
            var propDict = new Dictionary<string, MaterialProperty>();

            foreach (var prop in properties)
            {
                propDict[prop.name] = prop;
            }

            return propDict;
        }

        public static string Text(string str)
        {
            string text = str;
            if (propNameValuedict.ContainsKey(str))
                text = propNameValuedict[str];

            return text;
        }

    }
}
#endif