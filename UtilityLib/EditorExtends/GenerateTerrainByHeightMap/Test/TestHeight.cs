using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
[CustomEditor(typeof(TestHeight))]
public class TestHeightEditor : Editor
{
    TestHeight inst;
    public override void OnInspectorGUI()
    {
        inst = target as TestHeight;

        base.OnInspectorGUI();

        if (GUILayout.Button("Test"))
        {
            inst.Generate();
        }
    }
}
#endif

public class TestHeight : MonoBehaviour
{
    public Texture2D tex;
    // Start is called before the first frame update
    public void Generate()
    {
        var t = GetComponent<Terrain>();
        var td = t.terrainData;

        var w = tex.width;
        var res = w + 1;

        td.size = new Vector3(w, 20, w);

        var heights = new float[res, res];
        var colors = tex.GetPixels();

        for (int y = 0; y < res; y++)
        {
            for (int x = 0; x < res; x++)
            {
                var idX = x == 0 ? 0 : x - 1;
                var idY = y == 0 ? 0 : y - 1;
                heights[y, x] = colors[idX + idY * w].r;
            }
        }
        
        //td.heightmapResolution = 1;
        td.SetHeights(0, 0, heights);
        Debug.Log(td.heightmapResolution);
    }


}
