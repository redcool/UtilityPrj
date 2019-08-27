namespace MyTools
{
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using UnityEngine;

    public static class PathTools
    {
        public static string GetAssetAbsPath(string assetPath)
        {
            return Application.dataPath + "/" + assetPath.Substring("Assets".Length);
        }

        public static string GetAssetPath(string absPath)
        {
            var index = absPath.IndexOf("Assets");
            if (index != -1)
                return absPath.Substring(index);
            return absPath;
        }

        public static void CreateAbsFolderPath(string assetPath)
        {
            var absPath = GetAssetAbsPath(assetPath);
            var dirPath = absPath;

            var extName = Path.GetExtension(assetPath);
            if (!string.IsNullOrEmpty(extName))
            {
                dirPath = Path.GetDirectoryName(absPath);
            }

            if (!Directory.Exists(dirPath))
            {
                Directory.CreateDirectory(dirPath);
            }
        }
    }
}