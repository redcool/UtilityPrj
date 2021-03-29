#if UNITY_EDITOR
namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEditor;
    using System;

    public static class TextureTools
    {
        static List<TextureImporterFormat> uncompressionFormats = new List<TextureImporterFormat>(new []{
            TextureImporterFormat.ARGB32,
            TextureImporterFormat.RGB24,
            TextureImporterFormat.RGBA32,
            TextureImporterFormat.RGBAHalf,
        });

        public static TextureImporter GetTextureImporter(this Texture tex)
        {
            var path = AssetDatabase.GetAssetPath(tex);
            return AssetImporter.GetAtPath(path) as TextureImporter;
        }
        public static void Setting(this Texture tex, Action<TextureImporter> onSetup)
        {
            if (onSetup == null)
                return;

            onSetup.Invoke(tex.GetTextureImporter());
        }

        public static bool IsCompressionFormat(this Texture tex,string platform)
        {
            var imp = tex.GetTextureImporter();
            var settings = imp.GetPlatformTextureSettings(platform);
            return !uncompressionFormats.Contains(settings.format);
        }
    }
}
#endif
