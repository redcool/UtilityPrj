using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
[CustomEditor(typeof(ShowHeightmap))]
public class ShowHeightmapEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var inst = target as ShowHeightmap;
        if (GUILayout.Button("Show"))
        {
            var t = inst.GetComponent<Terrain>();
            if (!t)
                return;
            inst.heightmap =  t.terrainData.heightmapTexture;
        }
    }
}
#endif

public class ShowHeightmap : MonoBehaviour
{
    public RenderTexture heightmap;

}
