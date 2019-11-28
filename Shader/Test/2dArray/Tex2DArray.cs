using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Tex2DArray : MonoBehaviour
{
    public Texture2D[] texs;

    public Texture2DArray texArr;
    public int width = 1024, height = 1024, depth = 4;
    // Start is called before the first frame update
    void Start()
    {
        var texArr = CreateTexArray(width,height,depth);
        AssetDatabase.CreateAsset(texArr, "Assets/Test/texArr.asset");
    }

    Texture2DArray CreateTexArray(int width,int height,int depth)
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
}
