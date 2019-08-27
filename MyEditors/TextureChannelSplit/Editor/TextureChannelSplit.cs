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

        [MenuItem("MyEditors/TextureTools/Split Selected Textures")]
        static void SplitSelectedTexutes()
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
                SplitRGBA(tex, out rgbTex, out alphaTex);

                //3 save rgb,a
                var path = AssetDatabase.GetAssetPath(tex);
                //var dir = Path.GetDirectoryName(path);
                //dir += "/" + tex.name;
                var dir = PathTools.GetAssetDir(path,"/",tex.name);
                var rgbTexPath = dir + "_rgb.png";
                var alphaTexPath = dir + "_r.png";

                Save(rgbTexPath, rgbTex);
                Save(alphaTexPath, alphaTex);
                var newAlphaPath = SaveAlphaTex(path);
                AssetDatabase.Refresh();

                //4 compress
                SetTextureFormat(newAlphaPath, rgbTexPath, alphaTexPath);
                //5
                AssetDatabase.Refresh();
            }
        }

        [MenuItem("MyEditors/TextureTools/Update Selected NGUI Atals")]
        static void UpdateSelectedAtals()
        {
            // get all uiAtlas
            var gos = EditorTools.GetFilteredFromSelection<GameObject>(SelectionMode.Assets | SelectionMode.DeepAssets);
            var q = gos.Where(go => go.GetComponent<UIAtlas>())
                .Select(go => go.GetComponent<UIAtlas>());
            Debug.Log(gos.Length + ":" + q.ToArray().Length);
            // get uiAtlas materials
            foreach (var item in q)
            {
                UpdateAtlasMaterial(item);
            }
            Debug.Log("UpdateSelectedAtals done.");
        }

        static void UpdateAtlasMaterial(UIAtlas atlas)
        {
            var assetPath = AssetDatabase.GetAssetPath(atlas);
            var prefabName = Path.GetFileNameWithoutExtension(assetPath);
            var path = PathTools.GetAssetDir(assetPath, "/", prefabName);

            var rgbTex = AssetDatabase.LoadAssetAtPath<Texture2D>(path + "_rgb.png");
            var rTex = AssetDatabase.LoadAssetAtPath<Texture2D>(path + "_r.png");
            var alphaTex = AssetDatabase.LoadAssetAtPath<Texture2D>(path + "_alpha.png");

            var mat = atlas.spriteMaterial;
            mat.shader = Shader.Find("Unlit/Transparent Colored (rgb+a)");
            mat.SetTexture("_MainTex", rgbTex);
            mat.SetTexture("_AlphaTex", rTex);

#if UNITY_ANDROID
            // rgb + alpha
            mat.SetTexture("_AlphaTex", alphaTex);
            mat.EnableKeyword("_ALPHATEXCHANNEL_A");
            mat.SetFloat("_AlphaTexChannel", 1);
#endif
        }

        static void SplitRGBA(Texture2D tex, out Texture2D rgbTex, out Texture2D alphaTex)
        {
            var colors = tex.GetPixels();
            var rgbs = colors.Select((c) => new Color(c.r, c.g, c.b)).ToArray();
            var alphas = colors.Select(c => new Color(c.a, 0, 0)).ToArray();

            rgbTex = new Texture2D(tex.width, tex.height);
            alphaTex = new Texture2D(tex.width, tex.height);

            rgbTex.SetPixels(rgbs);
            rgbTex.Apply();

            alphaTex.SetPixels(alphas);
            alphaTex.Apply();
        }

        static void Save(string assetPath, Texture2D tex)
        {
            var absPath = PathTools.GetAssetAbsPath(assetPath);
            File.WriteAllBytes(absPath, tex.EncodeToPNG());
        }

        static string SaveAlphaTex(string path)
        {
            // new ui atlas 
            var absPath = PathTools.GetAssetAbsPath(path);
            var newFilePath = Path.GetDirectoryName(absPath) + "/" + Path.GetFileNameWithoutExtension(absPath) + "_alpha" + Path.GetExtension(absPath);
            File.Copy(absPath, newFilePath, true);
            return PathTools.GetAssetPath(newFilePath);
        }

        static void SetTextureFormat(string path, string rgbTexPath, string alphaTexPath)
        {
            // prepare settings
            var alphaTexSeting = new TextureImporterPlatformSettings
            {
                format = TextureImporterFormat.Alpha8
            };

            var rgbTexSeting = new TextureImporterPlatformSettings();
            rgbTexSeting.textureCompression = TextureImporterCompression.Compressed;

            if (Application.platform == RuntimePlatform.IPhonePlayer)
                rgbTexSeting.format = TextureImporterFormat.PVRTC_RGB4;
            else if (Application.platform == RuntimePlatform.Android)
                rgbTexSeting.format = TextureImporterFormat.ETC_RGB4;

            var setings = new[] { alphaTexSeting, rgbTexSeting, rgbTexSeting };
            var texPaths = new[] { path, rgbTexPath, alphaTexPath };

            for (int i = 0; i < setings.Length; i++)
            {
                AssetDatabase.LoadAssetAtPath<Texture2D>(PathTools.GetAssetPath(texPaths[i])).Setting(
                    imp =>
                    {
                        imp.SetPlatformTextureSettings(setings[i]);
                        imp.mipmapEnabled = false;
                        imp.SaveAndReimport();
                    }
                    );
            }
        }
    }
}
#endif