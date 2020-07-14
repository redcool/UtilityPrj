using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Create3D
{
    [MenuItem("Test/Create3D")]
    static void StartCreate3D()
    {
        int width = 128,height=128,depth=128;
        var mul = 1f / (width - 1);

        var index = 0;
        //for (int x = 0; x < width; x++)
        //{
        //    for (int y = 0; y < height; y++)
        //    {
        //        for (int z = 0; z < depth; z++)
        //        {
        //            colors[index++] = new Color(x * mul, y * mul, z * mul);
        //        }
        //    }
        //}

        List<Color> colorList = new List<Color>();
        for (int z = 0; z < depth; z++)
        {
            colorList.AddRange(SimplexNoise.GenerateNoise(width, height));
        }

        var tex = new Texture3D(width, height, depth, TextureFormat.RGB24, true);
        tex.SetPixels(colorList.ToArray());
        tex.Apply();

        AssetDatabase.CreateAsset(tex,"Assets/Temp/vol.asset");
    }
}
