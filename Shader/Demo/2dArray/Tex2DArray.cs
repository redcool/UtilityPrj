using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR

using UnityEditor;
[CustomEditor(typeof(Tex2DArray))]
public class Tex2DArrayEditor : Editor
{
    Texture2DArray CreateTexArray(int width, int height, int depth,Texture2D[] texs)
    {
        var texArr = new Texture2DArray(width, height, depth, TextureFormat.RGB24, true);

        int index = 0;
        foreach (var item in texs)
        {
            //Graphics.CopyTexture(item, 0, texArr, index++);

            texArr.SetPixels(item.GetPixels(), index++);
        }
        texArr.Apply();
        return texArr;
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("Create"))
        {
            var t = ((Tex2DArray)target);

            var texArr = CreateTexArray(t.width, t.height, t.depth, t.texs);
            AssetDatabase.CreateAsset(texArr, "Assets/Test/texArr.asset");
        }
    }
}
#endif

public class Tex2DArray : MonoBehaviour
{
    public Texture2D[] texs;

    public int width = 1024, height = 1024, depth = 4;
}
