using MyTools;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class TileTerrainWindow : EditorWindow
{
    public const string ROOT_PATH = "MyEditors/Terrain/Command";
    Terrain terrainObj;
    Material terrainMat;

    int tileCount=1, countZ=1;

    public enum SaveResolution { Full, Half, Quarter, Eighth, Sixteeth }
    SaveResolution saveResolution = SaveResolution.Half;

    [MenuItem(ROOT_PATH + "/Tile Terrain Window")]
    static void Init()
    {
        var win = GetWindow<TileTerrainWindow>();
        win.Show();
    }

    private void OnGUI()
    {
        terrainObj = (Terrain)EditorGUILayout.ObjectField("Terrain:",terrainObj, typeof(Terrain), true);
        if (!terrainObj)
        {
            EditorGUILayout.HelpBox("需要先拖放一个terrain", MessageType.Info);
            return;
        }

        saveResolution = (SaveResolution)EditorGUILayout.EnumPopup("Save Resolution:",saveResolution);

        tileCount = Mathf.Max(1, EditorGUILayout.IntField("Tile Count:",Mathf.NextPowerOfTwo(tileCount)));
        terrainMat = (Material)EditorGUILayout.ObjectField("Terrain Material:",terrainMat, typeof(Material), false);

        if (GUILayout.Button("Export"))
        {
            var terrainGo = new GameObject("Terrain Mesh");
            GenerateTiles(terrainObj, tileCount, terrainGo.transform, terrainMat,saveResolution);
        }
    }

    static void GenerateTiles(Terrain terrain,int tileCount,Transform parent,Material mat,SaveResolution saveResolution)
    {
        var resScale = (int)Mathf.Pow(2, (int)saveResolution);

        var td = terrain.terrainData;

        var heightmapSize = (td.heightmapResolution - 1) / tileCount ;

        var id = 0;
        var count = tileCount * tileCount;

        for (int x = 0; x < tileCount; x++)
        {
            for (int z = 0; z < tileCount; z++)
            {
                var heightmapRect = new RectInt(x * heightmapSize, z * heightmapSize, heightmapSize + 1, heightmapSize + 1);
                var tileMesh = TerrainTools.GenerateTileMesh(terrain, heightmapRect, resScale);

                GenerateTileGo(string.Format("Tile-{0}_{1}", x, z),tileMesh, parent, mat);
                id++;

                DisplayProgress(id,count);
            }
        }
    }

    public static void GenerateTileGo(string name,Mesh mesh,Transform parent,Material mat)
    {
        var tileGo = new GameObject(name);
        tileGo.transform.SetParent(parent);

        var mr = tileGo.AddComponent<MeshRenderer>();
        mr.sharedMaterial = mat;

        var mf = tileGo.AddComponent<MeshFilter>();
        mf.sharedMesh = mesh;

        tileGo.AddComponent<MeshCollider>();
    }

    static void DisplayProgress(int id,int count)
    {
        EditorUtility.DisplayProgressBar("Progress", "Export Progress", (float)id / count);
        if (id == count)
            EditorUtility.ClearProgressBar();
    }
    
    
}
