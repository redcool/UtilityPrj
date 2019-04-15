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