#if UNITY_EDITOR
namespace PowerUtilities
{
    using UnityEditor;
    using System;
    using static PowerUtilities.HeightMapTerrainGenerator;
    using System.IO;
    using System.Linq;
    using UnityEngine;
    using System.Collections.Generic;

    /// <summary>
    /// HeightMapTerrainGenerator Editor
    /// </summary>
    [CustomEditor(typeof(HeightMapTerrainGenerator))]
    public class HeightMapTerrainGeneratorEditor : Editor
    {
        HeightMapTerrainGenerator inst;
        private bool showGeneratedTerrains;

        public override void OnInspectorGUI()
        {
            serializedObject.UpdateIfRequiredOrScript();

            inst = target as HeightMapTerrainGenerator;

            EditorGUI.BeginChangeCheck();
            //base.OnInspectorGUI();
            //EditorGUILayout.Space(100);


            DrawHeightmapsUI();

            EditorGUILayout.Space(8);

            DrawGenerateTerrainUI();

            DrawUpdateTerrainTileUI();
            DrawMaterialUI();

            if (EditorGUI.EndChangeCheck())
            {
                UpdateTerrainProperties();
            }

            serializedObject.ApplyModifiedProperties();
        }

        private void DrawHeightmapsUI()
        {
            EditorGUILayout.BeginVertical("Box");
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.heightmaps)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.heightMapResolution)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.splitTextureList)));

                if (inst.heightmaps != null && inst.heightmaps.Length > 0)
                {
                    // split textures
                    EditorGUILayout.LabelField("Textures");

                    EditorGUILayout.BeginHorizontal("Box");
                    if (GUILayout.Button("Split Heightmaps"))
                    {
                        inst.heightmaps = inst.heightmaps.Where(hm => hm).ToArray();
                        inst.splitTextureList = TextureTools.SplitTextures(inst.heightmaps, inst.heightMapResolution, ref inst.countInRow);
                    }
                    if (GUILayout.Button("Save Heightmaps"))
                    {
                        TextureTools.SaveTexturesDialog(inst.splitTextureList, inst.countInRow);
                    }
                    EditorGUILayout.EndHorizontal();
                }
            }
            EditorGUILayout.EndVertical();
        }
        private void DrawGenerateTerrainUI()
        {
            EditorGUILayout.BeginVertical("Box");
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.countInRow)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.terrainSize)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.pixelError)));
                // generate tile terrains
                if (inst.splitTextureList != null && inst.splitTextureList.Count > 0)
                {
                    EditorGUILayout.LabelField("Terrains");
                    if (GUILayout.Button("Generate Terrains"))
                    {
                        inst.generatedTerrainList = GenerateTerrains(inst.transform, inst.splitTextureList, inst.countInRow, inst.terrainSize, inst.materialTemplate);
                    }
                    showGeneratedTerrains = EditorGUILayout.Foldout(showGeneratedTerrains, "Show generatedTerrainList");
                    if (showGeneratedTerrains)
                    {
                        EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.generatedTerrainList)));
                    }
                }
            }
            EditorGUILayout.EndVertical();
        }

        private void DrawUpdateTerrainTileUI()
        {
            // update tile
            if (inst.splitTextureList != null && inst.splitTextureList.Count > 0
                && inst.generatedTerrainList != null && inst.generatedTerrainList.Count > 0)
            {
                EditorGUILayout.BeginVertical("Box");
                EditorGUILayout.PrefixLabel("Generate Terrain Tile by heightmap's id");

                EditorGUILayout.BeginHorizontal("Box");
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.updateTerrainId)));

                inst.updateTerrainId = Mathf.Clamp(inst.updateTerrainId, 0, inst.splitTextureList.Count - 1);

                if (GUILayout.Button("Update Terrain Tile"))
                {
                    GenerateTerrainById(inst.generatedTerrainList, inst.splitTextureList, inst.updateTerrainId);
                }
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.EndVertical();
            }
        }

        private void DrawMaterialUI()
        {
            EditorGUILayout.BeginVertical("Box");
            // draw material
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.materialTemplate)));
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.terrainLayers)));
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.controlMaps)));
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.controlMapResolution)));


            EditorGUILayout.BeginHorizontal("Box");
            if(GUILayout.Button("Split ControlMap"))
            {
                inst.controlMaps = inst.controlMaps.Where(t => t).ToArray();
                inst.spliatedControlMaps = TextureTools.SplitTextures(inst.controlMaps, inst.controlMapResolution, ref inst.controlMapCountInRow);
            }
            if (GUILayout.Button("Save ControlMaps"))
                TextureTools.SaveTexturesDialog(inst.spliatedControlMaps, inst.controlMapCountInRow);

            EditorGUILayout.EndHorizontal();


            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.spliatedControlMaps)));
            if(GUILayout.Button("Reassign ControlMaps"))
            {
                AssignControlMaps(inst.generatedTerrainList,inst.spliatedControlMaps,inst.terrainLayers);
            }

            EditorGUILayout.EndVertical();
        }

        private void AssignControlMaps(List<Terrain> terrains,List<Texture2D> controlMaps,TerrainLayer[] allTerrainLayers)
        {
            for (int i = 0; i < terrains.Count; i++)
            {
                var terrain = terrains[i];
                var controlMap = controlMaps[i];

                terrain.terrainData.terrainLayers = allTerrainLayers;
                terrain.materialTemplate = inst.materialTemplate;

                var td = terrain.terrainData;
                td.ApplyAlphamap(new[] { controlMap });
            }
        }

        private void UpdateTerrainProperties()
        {
            var terrains = inst.GetComponentsInChildren<Terrain>();
            foreach (var item in terrains)
            {
                item.heightmapPixelError = inst.pixelError;
                item.materialTemplate = inst.materialTemplate;
            }
        }

        void GenerateTerrainById(List<Terrain> terrains, List<Texture2D> heightmaps, int heightmapId)
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

        List<Terrain> GenerateTerrains(Transform rootTr, List<Texture2D> heightmaps, int countInRow, Vector3 terrainSize, Material mat)
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

                    t.transform.SetParent(terrainRootGo.transform, false);
                    t.transform.position = Vector3.Scale(terrainSize, new Vector3(x, 0, y));

                    var c = go.AddComponent<TerrainCollider>();
                    c.terrainData = t.terrainData;

                    t.materialTemplate = Instantiate(mat);
                }
                //break;
            }
            return terrainList;
        }

    }
}
#endif
