namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

#if UNITY_EDITOR
    using UnityEditor;
    using System;
    using static PowerUtilities.HeightMapTerrainGenerator;
    using System.IO;

    [CustomEditor(typeof(HeightMapTerrainGenerator))]
    public class HeightMapTerrainGeneratorEditor : Editor
    {
        HeightMapTerrainGenerator inst;
        public override void OnInspectorGUI()
        {
            inst = target as HeightMapTerrainGenerator;

            EditorGUI.BeginChangeCheck();
            base.OnInspectorGUI();
            if (EditorGUI.EndChangeCheck())
            {
                UpdateProperties();
            }

            EditorGUILayout.BeginHorizontal("");
            {
                // split textures
                EditorGUILayout.BeginVertical("Box");
                EditorGUILayout.LabelField("Textures");
                if (GUILayout.Button("Split Heightmaps"))
                {
                    inst.splitTextureList = SplitTextures(inst.heightmaps, inst.heightMapResolution, ref inst.countInRow);
                }
                if(GUILayout.Button("Save Heightmaps"))
                {
                    SaveTextures(inst.splitTextureList,inst.countInRow);
                }
                EditorGUILayout.EndVertical();

                EditorGUILayout.Space(8);

                // generate tile terrains
                EditorGUILayout.BeginVertical("Box");
                EditorGUILayout.LabelField("Terrains");
                if (GUILayout.Button("Generate Terrains"))
                {
                    GenerateTerrains(inst.transform,inst.splitTextureList, inst.countInRow,inst.terrainSize,inst.material);
                }
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndHorizontal();
        }

        private void SaveTextures(List<Texture2D> splitTextureList,int countInRow)
        {
            if (splitTextureList == null)
                return;

            var folder = EditorUtility.SaveFolderPanel("Save SplitedTextures", "", "");
            if (string.IsNullOrEmpty(folder))
                return;

            TextureTools.SaveTextures(splitTextureList, folder, countInRow);
        }

        private void UpdateProperties()
        {
            var terrains = inst.GetComponentsInChildren<Terrain>();
            foreach (var item in terrains)
            {
                item.heightmapPixelError = inst.pixelError;
            }
        }

        List<Texture2D> SplitTextures(Texture2D[] heightmaps, HeightMapResolution resolution, ref int countInRow)
        {
            if (heightmaps == null)
                return null;

            var res = (int)resolution;
            var textureList = new List<Texture2D>();
            countInRow = 0;

            for (int i = 0; i < heightmaps.Length; i++)
            {
                var heightmap = heightmaps[i];
                var countInRowTile = heightmap.width / res;

                countInRow += countInRowTile;

                if (heightmap.width > res)
                {
                    var texs = heightmap.SplitTexture(res);
                    textureList.AddRange(texs);
                }
                else
                {
                    textureList.Add(heightmap);
                }
            }
            return textureList;
        }

        void GenerateTerrains(Transform rootTr,List<Texture2D> heightmaps, int countInRow,Vector3 terrainSize,Material mat)
        {
            if (heightmaps == null)
                return;

            // cleanup
            foreach (Transform item in rootTr)
            {
                DestroyImmediate(item.gameObject);
            }

            // calc rows
            var count = heightmaps.Count;
            var rows = count / countInRow;
            if (count % countInRow > 0)
                rows++;
            
            // get root go
            var terrainRootGo = new GameObject("Terrains");
            terrainRootGo.transform.SetParent(rootTr, false);

            // generate terrain go
            var heightMapId = 0;
            for (int y = 0; y < rows; y++)
            {
                for (int x = 0; x < countInRow; x++)
                {
                    var go = new GameObject(string.Format("Terrain Tile [{0},{1}]", x, y));
                    var t = go.AddComponent<Terrain>();
                    t.terrainData = new TerrainData();
                    t.terrainData.ApplyHeightmap(heightmaps[heightMapId++]);
                    t.terrainData.size = terrainSize;

                    t.transform.SetParent(terrainRootGo.transform,false);
                    t.transform.position = Vector3.Scale(terrainSize,new Vector3(x,0,y));

                    var c = go.AddComponent<TerrainCollider>();
                    c.terrainData = t.terrainData;

                    t.materialTemplate = mat;
                }
                //break;
            }
        }

    }
#endif
    /// <summary>
    /// Generate Terrains by Heightmaps 
    /// function : 
    /// 1 split heightmaps to tile heightmaps
    /// 2 generate terrain tile by heightmaps
    /// </summary>
    public class HeightMapTerrainGenerator : MonoBehaviour
    {
        public enum HeightMapResolution
        {
            x32=32,x64=64,x128=128,x256=256,x512=512,x1024=1024,x2048=2048,x4096=4096
        }

        public Texture2D[] heightmaps;
        public List<Texture2D> splitTextureList;
        public int countInRow = 1;
        public HeightMapResolution heightMapResolution = HeightMapResolution.x256;
        public Vector3 terrainSize = new Vector3(1000,600,1000);
        public Material material;
        [Min(0)]public int pixelError = 100;
    }
}