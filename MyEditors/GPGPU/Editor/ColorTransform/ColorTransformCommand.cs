#if UNITY_EDITOR
using MyTools;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace MyEditors
{
    public static class ColorTransformCommand
    {
        [MenuItem("MyEditors/GPGPU/ColorTransform")]
        static void Init()
        {
            var tex = EditorTools.GetFirstFilteredFromSelection<Texture>(SelectionMode.Assets);
            var mat = EditorTools.GetFirstFilteredFromSelection<Material>(SelectionMode.Assets);

            if (!tex || !mat)
            {
                Debug.Log("Need select a Texture and a Material.");
                return;
            }

            var t = Run(tex, mat);
            mat.SetTexture("_Control", tex);
            Debug.Log(mat.GetTexture("_Splat0"));
            if (t)
            {
                var path = "Assets/Tmp/trans.jpg";
                PathTools.CreateAbsFolderPath(path);
                File.WriteAllBytes(path,t.EncodeToJPG());

                AssetDatabase.Refresh();
                EditorGUIUtility.PingObject(AssetDatabase.LoadAssetAtPath<Texture>(path));
            }
        }

        static Texture2D Run(Texture tex, Material mat)
        {
            var rt = RenderTexture.GetTemporary(tex.width, tex.height);
            Graphics.Blit(tex, rt, mat);

            var t = new Texture2D(rt.width, rt.height);

            var lastRt = RenderTexture.active;
            RenderTexture.active = rt;
            t.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            t.Apply();
            RenderTexture.active = lastRt;
            RenderTexture.ReleaseTemporary(rt);

            return t;
        }
        
    }
}
#endif