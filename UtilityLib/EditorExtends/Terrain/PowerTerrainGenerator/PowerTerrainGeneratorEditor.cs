#if UNITY_EDITOR
namespace PowerUtilities
{
    using UnityEditor;
    using System;
    using static PowerUtilities.PowerTerrainGenerator;
    using System.IO;
    using System.Linq;
    using UnityEngine;
    using System.Collections.Generic;
    using Object = UnityEngine.Object;

    /// <summary>
    /// HeightMapTerrainGenerator Editor
    /// </summary>
    [CustomEditor(typeof(PowerTerrainGenerator))]
    public class PowerTerrainGeneratorEditor : Editor
    {
        const string helpStr = @"
高度图Terrain生成器

根据高度图生成Terrain块
1 heightmap
    1.1 切分
    1.2 保存
2 生成Terrain
    2.1 根据切分的高度图,生成对应的Terrain 块
    2.2 指定Terrain id,根据对应的heightmap id,重生成Terrain
3 管理 地形块设置
4 controlMap
    4.1 切分controlMap
    4.2 保存切分的controlMap
    4.3 指定对应的controlMap到对应的Terrain块

";
        PowerTerrainGenerator inst;

        (string title, bool fold) heightmapFold = ("Heightmaps", false);
        (string title, bool fold) terrainFold = ("Generate Terrains",false);
        (string title, bool fold) materialFold = ("Material",false);
        (string title, bool fold) controlMapFold= ("Control Map", false);
        (string title, bool fold) settingsFold = ("Settings", false);
        (string title, bool fold) generatedTerrainsFold = ("Generated Terrains", false);


        public override void OnInspectorGUI()
        {
            EditorGUILayout.HelpBox(helpStr, MessageType.Info);

            serializedObject.UpdateIfRequiredOrScript();

            inst = target as PowerTerrainGenerator;

            EditorGUI.BeginChangeCheck();

            EditorGUITools.DrawFoldContent(ref heightmapFold, () => DrawHeightmapsUI());
            EditorGUITools.DrawFoldContent(ref terrainFold, () =>
            {
                DrawGenerateTerrainUI();
                DrawUpdateTerrainTileUI();
            });
            EditorGUITools.DrawFoldContent(ref materialFold, () => DrawMaterialUI(),Color.yellow);
            EditorGUITools.DrawFoldContent(ref controlMapFold, () => DrawControlMapUI());
            EditorGUITools.DrawFoldContent(ref settingsFold, () => DrawTerrainSettings(), Color.yellow);

            if (EditorGUI.EndChangeCheck())
            {
                UpdateTerrainProperties();
            }

            serializedObject.ApplyModifiedProperties();
        }

        void DrawHeightmapsUI()
        {
            EditorGUILayout.BeginVertical("Box");
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.heightmaps)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.heightMapResolution)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.splitedHeightmapList)));

                if (inst.heightmaps != null && inst.heightmaps.Length > 0)
                {
                    // split textures
                    EditorGUILayout.LabelField("Textures");

                    EditorGUILayout.BeginHorizontal("Box");
                    if (GUILayout.Button("Split Heightmaps"))
                    {
                        inst.heightmaps = inst.heightmaps.Where(hm => hm).ToArray();
                        inst.splitedHeightmapList = TextureTools.SplitTextures(inst.heightmaps, inst.heightMapResolution, ref inst.countInRow);
                    }
                    if (GUILayout.Button("Save Heightmaps"))
                    {
                        TextureTools.SaveTexturesDialog(inst.splitedHeightmapList, inst.countInRow);
                    }
                    EditorGUILayout.EndHorizontal();
                }
            }
            EditorGUILayout.EndVertical();
        }

        void DrawTerrainSettings()
        {
            EditorGUILayout.BeginVertical("Box");
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.pixelError)));
            }
            EditorGUILayout.EndVertical();
        }

        void DrawGenerateTerrainUI()
        {
            EditorGUILayout.BeginVertical("Box");
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.countInRow)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.terrainSize)));
                // generate tile terrains
                if (inst.splitedHeightmapList != null && inst.splitedHeightmapList.Count > 0)
                {
                    EditorGUILayout.LabelField("Terrains");
                    if (GUILayout.Button("Generate Terrains"))
                    {
                        inst.generatedTerrainList = TerrainTools.GenerateTerrainsByHeightmaps(inst.transform, inst.splitedHeightmapList, inst.countInRow, inst.terrainSize, inst.materialTemplate);
                    }

                    EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.generatedTerrainList)));
                }
            }
            EditorGUILayout.EndVertical();
        }

        void DrawUpdateTerrainTileUI()
        {
            // update tile
            if (inst.splitedHeightmapList != null && inst.splitedHeightmapList.Count > 0
                && inst.generatedTerrainList != null && inst.generatedTerrainList.Count > 0)
            {
                EditorGUILayout.BeginVertical("Box");
                EditorGUILayout.PrefixLabel("Generate one terrain tile");

                EditorGUILayout.BeginHorizontal("Box");
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.updateTerrainId)));

                inst.updateTerrainId = Mathf.Clamp(inst.updateTerrainId, 0, inst.splitedHeightmapList.Count - 1);

                if (GUILayout.Button("Update Terrain Tile"))
                {
                    GenerateTerrainById(inst.generatedTerrainList, inst.splitedHeightmapList, inst.updateTerrainId);
                }
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.EndVertical();
            }
        }

        void DrawMaterialUI()
        {
            EditorGUILayout.BeginVertical("Box");
            {
                // draw material
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.materialTemplate)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.terrainLayers)));
            }
            EditorGUILayout.EndVertical();
        }
        void UpdateTerrainProperties()
        {
            var terrains = inst.GetComponentsInChildren<Terrain>();
            foreach (var item in terrains)
            {
                item.heightmapPixelError = inst.pixelError;
                item.materialTemplate = inst.materialTemplate;
                item.terrainData.terrainLayers = inst.terrainLayers;
            }
        }
        void DrawControlMapUI()
        {
            EditorGUILayout.BeginVertical("Box");
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.controlMaps)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.controlMapResolution)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.controlMapCountInRow)));

                EditorGUILayout.BeginHorizontal("Box");
                {
                    if (GUILayout.Button("Split ControlMap"))
                    {
                        inst.controlMaps = inst.controlMaps.Where(t => t).ToArray();
                        inst.splitedControlMaps = TextureTools.SplitTextures(inst.controlMaps, inst.controlMapResolution, ref inst.controlMapCountInRow);
                    }
                    if (GUILayout.Button("Save ControlMaps"))
                        TextureTools.SaveTexturesDialog(inst.splitedControlMaps, inst.controlMapCountInRow);

                }
                EditorGUILayout.EndHorizontal();


                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.splitedControlMaps)));
                if (GUILayout.Button("Reassign ControlMaps"))
                {
                    AssignSplitedControlMaps(inst.generatedTerrainList, inst.terrainLayers, inst.splitedControlMaps, inst.controlMaps.Length);
                }

            }
            EditorGUILayout.EndVertical();
        }

        void AssignSplitedControlMaps(List<Terrain> terrains, TerrainLayer[] terrainLayers, List<Texture2D> splitedControlMaps, int controlMapLayers)
        {
            if (terrains == null || terrainLayers == null || splitedControlMaps == null)
                return;

            //
            var controlMapCountInTerrainTile = splitedControlMaps.Count / controlMapLayers;

            for (int terrainId = 0; terrainId < terrains.Count; terrainId++)
            {
                var terrain = terrains[terrainId];

                var controlMaps = new Texture2D[controlMapLayers]; // a tile terrain can has multi controlmaps.
                for (int layerId = 0; layerId < controlMapLayers; layerId++)
                {
                    controlMaps[layerId] = splitedControlMaps[terrainId + layerId * controlMapCountInTerrainTile];
                }

                terrain.terrainData.terrainLayers = terrainLayers;
                terrain.materialTemplate = inst.materialTemplate;

                var td = terrain.terrainData;
                td.ApplyAlphamaps(controlMaps);

                EditorUtility.DisplayProgressBar("ApplyAlphamaps ", "", (float)terrainId / terrains.Count);
            }
            EditorUtility.ClearProgressBar();
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

    }
}
#endif
