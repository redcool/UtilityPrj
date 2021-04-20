﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace PowerUtilities
{
    public enum TextureResolution
    {
        x32 = 32, x64 = 64, x128 = 128, x256 = 256, x512 = 512, x1024 = 1024, x2048 = 2048, x4096 = 4096
    }

    public static class Texture2DEx
    {

#if UNITY_EDITOR
        static List<TextureImporterFormat> uncompressionFormats = new List<TextureImporterFormat>(new[]{
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

            onSetup(tex.GetTextureImporter());
        }

        public static bool IsCompressionFormat(this Texture tex, string platform)
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
#endif

        /// <summary>
        /// split texture to textures
        /// texture need power of 2 , width == height
        /// </summary>
        /// <param name="tex"></param>
        /// <param name="resolution"></param>
        /// <returns></returns>
        public static Texture2D[] SplitTexture(this Texture2D tex, int resolution, Action<float> onProgress, bool isHeightmap)
        {
            if (tex.width <= resolution)
            {
                return new[] { tex };
            }

            tex.SetReadable(true);

            var texWidth = resolution + (isHeightmap ? 1 : 0);
            var texHeight = resolution + (isHeightmap ? 1 : 0);
            // splite texture
            var count = tex.width / resolution;
            var newTexs = new Texture2D[count * count];
            var texId = 0;

            for (int y = 0; y < count; y++)
            {
                for (int x = 0; x < count; x++)
                {
                    var blockWidth = resolution + (isHeightmap && x < count - 1 ? 1 : 0);
                    var blockHeight = resolution + (isHeightmap && y < count - 1 ? 1 : 0);

                    var newTex = newTexs[texId++] = new Texture2D(texWidth, texHeight, TextureFormat.R16, false);
                    newTex.Fill(Color.black);


                    newTex.SetPixels(0, 0, blockWidth, blockHeight, tex.GetPixels(x * resolution, y * resolution, blockWidth, blockHeight));
                    newTex.Apply();

                    if (onProgress != null)
                        onProgress((float)texId / newTexs.Length);
                }
            }
            return newTexs;
        }

        public static void Fill(this Texture2D tex, Color c)
        {
            for (int y = 0; y < tex.height; y++)
            {
                for (int x = 0; x < tex.width; x++)
                {
                    tex.SetPixel(x, y, c);
                }
            }
        }
    }
}
