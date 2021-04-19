namespace PowerUtilities
{
    using UnityEngine;
    using System.Collections;
    using System.Collections.Generic;
    using PowerUtilities;

#if UNITY_EDITOR
    using UnityEditor;
    [CustomEditor(typeof(TestAlphamap))]
    public class TestAlphamapEditor : Editor
    {
        TestAlphamap inst;
        public override void OnInspectorGUI()
        {
            inst = target as TestAlphamap;
            base.OnInspectorGUI();

            var terrain = inst.GetComponent<Terrain>();
            var path = "Assets/Test/TestTerrain.asset";

            if (GUILayout.Button("Save"))
            {

                var td = new TerrainData();

                td.terrainLayers = inst.terrayLayers;
                td.heightmapResolution = 513;
                td.alphamapResolution = 512;
                AssetDatabase.CreateAsset(td, path);

                var tdAsset = AssetDatabase.LoadAssetAtPath<TerrainData>(path);
                td.AddAlphaNoise(100);
                tdAsset.CopyAlphamapsFrom(td);
                terrain.terrainData = tdAsset;

                //var td = terrain.terrainData;

                //terrain.terrainData = td;


                //td.CopyActiveRenderTextureToTexture(TerrainData.AlphamapTextureName, 0, new RectInt(0, 0, 512, 512), new Vector2Int(0, 0), false);
                //td.SyncTexture(TerrainData.AlphamapTextureName);
                //AssetDatabase.SaveAssets();



                //terrain.terrainData = AssetDatabase.LoadAssetAtPath<TerrainData>(path);


            }

            if (GUILayout.Button("Noise"))
            {
                var tdAsset = AssetDatabase.LoadAssetAtPath<TerrainData>(path);
                tdAsset.AddAlphaNoise(100);
            }
        }
    }
#endif

    public class TestAlphamap : MonoBehaviour
    {
        public TerrainLayer[] terrayLayers;

        // Add some random "noise" to the alphamaps.


    }
}