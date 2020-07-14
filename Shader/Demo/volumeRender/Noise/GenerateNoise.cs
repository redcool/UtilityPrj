#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class GenerateNoise 
{
    [MenuItem("Noise/Generate")]
    static void Init()
    {
        const int size = 512;
        CreateNoiseTex(size, 1, "tex1.png");
        CreateNoiseTex(size, 5, "tex2.png");
        CreateNoiseTex(size, 10, "tex3.png");
        CreateNoiseTex(size, 20,"tex4.png");
        AssetDatabase.Refresh();
    }

    static void CreateNoiseTex(int size,float scale,string fileName)
    {
        var tex = SimplexNoise.GenerateNoiseTexture(size, size, scale, scale);
        var bytes = tex.EncodeToPNG();

        var dir = Application.dataPath + "/NoiseTex/";
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }
        var path = Path.Combine(dir, fileName);
        File.WriteAllBytes(path, bytes);
    }

    
}
#endif