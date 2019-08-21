#if UNITY_EDITOR
namespace MyTools
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEditor;
    using System.Linq;
    using System.IO;

    public class TextureChannelSplit
    {

        [MenuItem("Tools/Split Selected Textures")]
        static void Init()
        {
            var texs = EditorTools.GetFilteredFromSelection<Texture2D>(SelectionMode.Assets);
            foreach (var tex in texs)
            {
                Texture2D rgbTex;
                Texture2D alphaTex;
                //1 setttings
                tex.Setting(ti => {
                    ti.isReadable = true;
                    ti.SaveAndReimport();
                });
                //2 split channels
                Split(tex,out rgbTex,out alphaTex);

                //3 save rgb,a
                var path = AssetDatabase.GetAssetPath(tex);
                var dir = Path.GetDirectoryName(path);
                dir += "/" + tex.name;

                Save(dir + "_rgb.png", rgbTex);
                Save(dir + "_alpha.png", alphaTex);

                //4
                AssetDatabase.Refresh();
            }
        }

        static void Split(Texture2D tex,out Texture2D rgbTex,out Texture2D alphaTex)
        {
            var colors = tex.GetPixels();
            var rgbs = colors.Select((c) => new Color(c.r, c.g, c.b)).ToArray();
            var alphas = colors.Select(c => new Color(c.a, 0, 0)).ToArray();

            rgbTex = new Texture2D(tex.width,tex.height);
            alphaTex = new Texture2D(tex.width,tex.height);

            rgbTex.SetPixels(rgbs);
            rgbTex.Apply();

            alphaTex.SetPixels(alphas);
            alphaTex.Apply();
        }

        static void Save(string assetPath,Texture2D tex)
        {
            var absPath = PathTools.GetAssetAbsPath(assetPath);
            File.WriteAllBytes(absPath, tex.EncodeToPNG());
        }

    }
}
#endif