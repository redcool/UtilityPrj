using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR

using UnityEditor;
[CustomEditor(typeof(Tex2DArrayCreator))]
public class Tex2DArrayEditor : Editor
{
    Texture2DArray CreateTexArray(Texture2D[] texs,bool isLinear)
    {
        var tex = texs[0];
        var texArr = new Texture2DArray(tex.width, tex.height, texs.Length, tex.format,tex.mipmapCount>0,false);

        int index = 0;
        foreach (var item in texs)
        {
            Graphics.CopyTexture(item, 0, texArr, index);
            //for (int m = 0; m < item.mipmapCount; m++)
            //{
            //    Graphics.CopyTexture(item, 0, m, texArr,index, m);
            //}
            index++;
        }
        texArr.Apply(false,true);
        return texArr;
    }
    /*
    Texture2DArray CreateTexArray(Texture2D[] texs)
    {
        var texArr = new Texture2DArray(texs[0].width, texs[0].height, texs.Length, TextureFormat.RGB24, true);

        int index = 0;
        foreach (var item in texs)
        {
            texArr.SetPixels(item.GetPixels(), index++);
        }
        texArr.Apply();
        return texArr;
    }
    */

    public override void OnInspectorGUI()
    {
        var inst = ((Tex2DArrayCreator)target);
        base.OnInspectorGUI();
        if (GUILayout.Button("Create"))
        {

            var texArr = CreateTexArray(inst.texs, inst.isLinear);
            AssetDatabase.DeleteAsset("Assets/Test/texArr.asset");
            AssetDatabase.CreateAsset(texArr, "Assets/Test/texArr.asset");
        }

    }
}
#endif

public class Tex2DArrayCreator : MonoBehaviour
{
    public Texture2D[] texs;
    public bool isLinear = true;
}
