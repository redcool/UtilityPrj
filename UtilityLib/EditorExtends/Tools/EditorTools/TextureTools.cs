#if UNITY_EDITOR
namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEditor;
    using System;
    using System.IO;

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

        public static void SetReadable(this Texture tex, bool isReadable)
        {
            if (tex.isReadable == isReadable)
                return;

            var textureImporter = tex.GetTextureImporter();
            textureImporter.isReadable = isReadable;
            textureImporter.SaveAndReimport();
        }

        /// <summary>
        /// split texture to textures
        /// texture need power of 2 , width == height
        /// </summary>
        /// <param name="tex"></param>
        /// <param name="resolution"></param>
        /// <returns></returns>
        public static Texture2D[] SplitTexture(this Texture2D tex, int resolution)
        {
            if (tex.width <= resolution)
            {
                return new[] { tex };
            }

            tex.SetReadable(true);

            // splite texture
            var count = tex.width / resolution;
            var newTexs = new Texture2D[count * count];
            var id = 0;
            for (int y = 0; y < count; y++)
            {
                for (int x = 0; x < count; x++)
                {
                    var newTex = newTexs[id++] = new Texture2D(resolution, resolution);
                    newTex.SetPixels(tex.GetPixels(x * resolution, y * resolution, resolution, resolution));
                    newTex.Apply();
                }
            }
            return newTexs;
        }

        public static void SaveTextures(List<Texture2D> splitTextureList, string folder, int countInRow, bool showPropressBar = true)
        {
            for (int i = 0; i < splitTextureList.Count; i++)
            {
                var row = i / countInRow;
                var col = i % countInRow;

                var tex = splitTextureList[i];
                if (!tex)
                    continue;

                if (showPropressBar)
                    EditorUtility.DisplayProgressBar("SaveTextures", "Save Splited Textures", i);

                var bytes = tex.EncodeToPNG();
                File.WriteAllBytes(string.Format("{0}/{1}_{2}.png", folder, col, row), bytes);
            }
            if (showPropressBar)
                EditorUtility.ClearProgressBar();
        }
    }
}
#endif
