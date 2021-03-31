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
    using System.Linq;

    [CustomEditor(typeof(HeightMapTerrainGenerator))]
    public class HeightMapTerrainGeneratorEditor : Editor
    {
        HeightMapTerrainGenerator inst;
        

        bool titleFold;

        public override void OnInspectorGUI()
        {
            inst = target as HeightMapTerrainGenerator;

            EditorGUI.BeginChangeCheck();
            base.OnInspectorGUI();
            if (EditorGUI.EndChangeCheck())
            {
                UpdateProperties();
            }

            //titleFold = EditorGUILayout.Foldout(titleFold,"Operate");
            //if (!titleFold)
            //    return;

            EditorGUILayout.BeginVertical("");
            {
                if(inst.heightmaps != null && inst.heightmaps.Length > 0)
                {
                    // split textures
                    EditorGUILayout.BeginVertical("Box");
                    EditorGUILayout.LabelField("Textures");
                    if (GUILayout.Button("Split Heightmaps"))
                    {
                        inst.heightmaps = inst.heightmaps.Where(hm => hm).ToArray();

                        inst.splitTextureList = SplitTextures(inst.heightmaps, inst.heightMapResolution, ref inst.countInRow);
                    }
                    if (GUILayout.Button("Save Heightmaps"))
                    {
                        SaveTextures(inst.splitTextureList, inst.countInRow);
                    }
                    EditorGUILayout.EndVertical();
                }

                EditorGUILayout.Space(8);

                // generate tile terrains
                if(inst.splitTextureList != null && inst.splitTextureList.Count > 0)
                {
                    EditorGUILayout.BeginVertical("Box");
                    EditorGUILayout.LabelField("Terrains");
                    if (GUILayout.Button("Generate Terrains"))
                    {
                        inst.generatedTerrainList = GenerateTerrains(inst.transform, inst.splitTextureList, inst.countInRow, inst.terrainSize, inst.material);
                    }
                    EditorGUILayout.EndVertical();
                }

                // update tile
                if(inst.splitTextureList != null && inst.splitTextureList.Count > 0
                    && inst.generatedTerrainList != null && inst.generatedTerrainList.Count > 0)
                {
                    EditorGUILayout.BeginVertical("Box");
                    EditorGUILayout.PrefixLabel("Update Terrain Tile");
                    EditorGUILayout.BeginHorizontal("Box");
                    //updateTerrainId = EditorGUILayout.IntSlider(updateTerrainId,0,inst.splitTextureList.Count-1);
                    inst.updateTerrainId = EditorGUILayout.IntField(inst.updateTerrainId);
                    
                    inst.updateTerrainId = Mathf.Clamp(inst.updateTerrainId, 0, inst.splitTextureList.Count-1);

                    if (GUILayout.Button("Update Terrain Tile"))
                    {
                        GenerateTerrainById(inst.generatedTerrainList, inst.splitTextureList, inst.updateTerrainId);
                    }
                    EditorGUILayout.EndHorizontal();
                    EditorGUILayout.EndVertical();
                }
            }
            EditorGUILayout.EndVertical();
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
            if (heightmaps == null || heightmaps.Length == 0)
                return null;

            var res = (int)resolution;
            var textureList = new List<Texture2D>();
            countInRow = 0;

            for (int i = 0; i < heightmaps.Length; i++)
            {
                var heightmap = heightmaps[i];
                if (heightmap == null)
                    continue;

                var countInRowTile = heightmap.width / res;
                countInRowTile = Mathf.Max(1, countInRowTile);

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

        void GenerateTerrainById(List<Terrain> terrains, List<Texture2D> heightmaps,int heightmapId)
        {
            if (heightmaps == null || heightmapId < 0 || heightmapId >= heightmaps.Count)
                return;

            if (terrains == null)
                return;

            var heightmap = heightmaps[heightmapId];
            heightmap.SetReadable(true);

            var terrain = terrains[heightmapId];
            if (!terrain)
                return;

            terrain.terrainData.ApplyHeightmap(heightmap);
        }

        List<Terrain> GenerateTerrains(Transform rootTr,List<Texture2D> heightmaps, int countInRow,Vector3 terrainSize,Material mat)
        {
            if (heightmaps == null)
                return null;

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
            var terrainList = new List<Terrain>();
            for (int y = 0; y < rows; y++)
            {
                for (int x = 0; x < countInRow; x++)
                {
                    var go = new GameObject(string.Format("Terrain Tile [{0},{1}]", x, y));
                    var t = go.AddComponent<Terrain>();
                    terrainList.Add(t);

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
            return terrainList;
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

        [Header("Heightmap")]
        public Texture2D[] heightmaps;
        public HeightMapResolution heightMapResolution = HeightMapResolution.x256;

        [Header("Splited Heightmaps")]
        public List<Texture2D> splitTextureList;

        [Header("Terrain")]
        [Min(1)]public int countInRow = 1;
        public Vector3 terrainSize = new Vector3(1000,600,1000);
        public Material material;
        [Min(0)]public int pixelError = 100;

        [HideInInspector][Min(0)]public int updateTerrainId;
        [HideInInspector] public List<Terrain> generatedTerrainList;
    }
}