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
        const string saveRootFolder = "Assets";

        PowerTerrainGenerator inst;

        public override void OnInspectorGUI()
        {
            EditorGUILayout.HelpBox(helpStr, MessageType.Info);

            serializedObject.UpdateIfRequiredOrScript();

            inst = target as PowerTerrainGenerator;

            EditorGUI.BeginChangeCheck();

            EditorGUITools.DrawFoldContent(ref inst.heightmapFold, () => DrawHeightmapsUI());
            EditorGUITools.DrawFoldContent(ref inst.terrainFold, () =>
            {
                DrawGenerateTerrainUI();
                EditorGUILayout.Space(8);
                DrawUpdateTerrainTileUI();
            });
            EditorGUITools.DrawFoldContent(ref inst.materialFold, () => DrawMaterialUI(),Color.green);
            EditorGUITools.DrawFoldContent(ref inst.controlMapFold, () => DrawControlMapUI());
            EditorGUITools.DrawFoldContent(ref inst.settingsFold, () => DrawTerrainSettings(), Color.green);

            EditorGUITools.DrawFoldContent(ref inst.exportFold, () => DrawExportUI());
            EditorGUITools.DrawFoldContent(ref inst.saveOptionsFold, () => DrawSaveOptionsUI());

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

                var disabled = (inst.heightmaps == null || inst.heightmaps.Length == 0);
                EditorGUI.BeginDisabledGroup(disabled);
                {
                    // split textures
                    EditorGUILayout.LabelField("Textures");

                    EditorGUILayout.BeginHorizontal("Box");
                    if (GUILayout.Button("Split Heightmaps"))
                    {
                        inst.heightmaps = inst.heightmaps.Where(hm => hm).ToArray();
                        inst.splitedHeightmapList = TextureTools.SplitTextures(inst.heightmaps, inst.heightMapResolution, ref inst.heightMapCountInRow,(progress)=> {
                            EditorUtility.DisplayProgressBar("Split Heightmaps", "Split Heightmaps", progress);
                        });
                        EditorUtility.ClearProgressBar();
                    }
                    if (GUILayout.Button("Save Heightmaps"))
                    {
                        TextureTools.SaveTexturesDialog(inst.splitedHeightmapList, inst.heightMapCountInRow);
                    }
                    EditorGUILayout.EndHorizontal();
                }
                EditorGUI.EndDisabledGroup();

                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.splitedHeightmapList)));
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


        void SavePrefabs(List<Terrain> terrainList,string assetFolder,bool isCreateSubFolder)
        {
            if (terrainList == null || terrainList.Count == 0)
            {
                return;
            }
            PathTools.CreateAbsFolderPath(assetFolder);

            var prefabFolder = assetFolder;
            if(isCreateSubFolder)
                prefabFolder = AssetDatabase.GUIDToAssetPath(AssetDatabase.CreateFolder(assetFolder, "TerrainPrefabs"));

            for (int i = 0; i < terrainList.Count; i++)
            {
                var terrain = terrainList[i];

                if (!terrain || !terrain.terrainData)
                    continue;

                // create prefab
                var prefabPath = $"{prefabFolder}/{terrain.name}.prefab";
                PrefabUtility.SaveAsPrefabAssetAndConnect(terrain.gameObject, prefabPath, InteractionMode.UserAction);
            }
            EditorGUIUtility.PingObject(AssetDatabase.LoadAssetAtPath<Object>(prefabFolder));
        }

        void SaveTerrains(List<Terrain> terrainList,string assetFolder,bool isCreateSubFolder)
        {
            if (terrainList == null || terrainList.Count == 0)
                return;

            //Create folder
            PathTools.CreateAbsFolderPath(assetFolder);
            var dataFolder = assetFolder;
            if(isCreateSubFolder)
                dataFolder = AssetDatabase.GUIDToAssetPath(AssetDatabase.CreateFolder(assetFolder, "TerrainDatas"));

            for (int i = 0; i < terrainList.Count; i++)
            {
                var terrain = terrainList[i];
                if (!terrain)
                    continue;

                var td = terrain.terrainData;

                var assetPath = AssetDatabase.GetAssetPath(td);
                if (!td || !string.IsNullOrEmpty(assetPath))
                    continue;

                var dataPath = $"{dataFolder}/{terrain.name}.asset";
                AssetDatabase.CreateAsset(td, dataPath);

                // read from disk
                terrain.terrainData = AssetDatabase.LoadAssetAtPath<TerrainData>(dataPath);
            }
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            EditorGUIUtility.PingObject(AssetDatabase.LoadAssetAtPath<Object>(dataFolder));
        }

        private void RenameGeneratedTerrains(List<Terrain> terrainlist, int countInRow, string nameTemplate)
        {
            if (terrainlist == null || terrainlist.Count == 0)
            {
                return;
            }

            for (int i = 0; i < terrainlist.Count; i++)
            {
                var rowId = i % countInRow;
                var colId = i / countInRow;

                var go = terrainlist[i].gameObject;
                var name = string.Format(nameTemplate, rowId, colId);
                go.name = name;

                PrefabTools.RenamePrefab(go, name);
            }
        }

        void DrawSaveOptionsUI()
        {
            EditorGUILayout.BeginVertical("Box");
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.isCreateSubFolder)));
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.terrainDataSavePath)));
            EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.prefabSavePath)));
            EditorGUILayout.EndVertical();
        }

        void DrawExportUI()
        {
            var disabled = inst.generatedTerrainList == null || inst.generatedTerrainList.Count == 0;
            EditorGUI.BeginDisabledGroup(disabled);
            {
                if (disabled)
                {
                    EditorGUITools.DrawColorUI(() =>
                    {
                        EditorGUILayout.LabelField("warning : generatedTerrainList is empty");
                    }, Color.yellow, Color.yellow);
                }

                EditorGUILayout.BeginVertical("Box");
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.nameTemplate)));
                if (GUILayout.Button("Rename"))
                {
                    RenameGeneratedTerrains(inst.generatedTerrainList, inst.heightMapCountInRow, inst.nameTemplate);
                }
                EditorGUILayout.EndVertical();


                EditorGUILayout.BeginVertical("Box");
                if (GUILayout.Button("Save terrain prefabs"))
                {
                    RenameGeneratedTerrains(inst.generatedTerrainList, inst.heightMapCountInRow, inst.nameTemplate);
                    SavePrefabs(inst.generatedTerrainList,inst.prefabSavePath,inst.isCreateSubFolder);
                }
                EditorGUILayout.EndVertical();
            }
            EditorGUI.EndDisabledGroup();

        }


        void DrawGenerateTerrainUI()
        {
            EditorGUILayout.BeginVertical("Box");
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.heightMapCountInRow)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.terrainSize)));
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.terrainHeightmapScale)));
                // generate tile terrains
                var disabled = inst.splitedHeightmapList == null || inst.splitedHeightmapList.Count == 0;
                EditorGUI.BeginDisabledGroup(disabled);
                {
                    if (disabled)
                    {
                        EditorGUITools.DrawColorUI(()=> {
                            EditorGUILayout.LabelField("Waring : splitedHeightmapList is empty.");
                        },Color.yellow,Color.yellow);
                    }
                    EditorGUILayout.LabelField("Terrains");
                    if (GUILayout.Button("Generate Terrains"))
                    {
                        inst.generatedTerrainList = TerrainTools.GenerateTerrainsByHeightmaps(inst.transform, inst.splitedHeightmapList,inst.terrainHeightmapScale, inst.heightMapCountInRow, inst.terrainSize, inst.materialTemplate);
                        SaveTerrains(inst.generatedTerrainList,inst.terrainDataSavePath,inst.isCreateSubFolder);
                    }

                    EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.generatedTerrainList)));
                }
                EditorGUI.EndDisabledGroup();
            }
            EditorGUILayout.EndVertical();
        }

        void DrawUpdateTerrainTileUI()
        {
            var enabled = inst.splitedHeightmapList != null && inst.splitedHeightmapList.Count > 0
                && inst.generatedTerrainList != null && inst.generatedTerrainList.Count > 0;
            // update tile
            EditorGUI.BeginDisabledGroup(!enabled);
            {
                EditorGUILayout.BeginVertical("Box");

                if (!enabled)
                {
                    EditorGUITools.DrawColorUI(() => {
                        EditorGUILayout.LabelField("Warning : splitedHeightmapList or generatedTerrainList is empty");
                    }, Color.yellow, Color.yellow);
                }

                EditorGUILayout.PrefixLabel("Generate one terrain tile");

                EditorGUILayout.BeginHorizontal("Box");
                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.updateTerrainTile)));
                //EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(inst.updateTerrainId)));
                //inst.updateTerrainId = Mathf.Clamp(inst.updateTerrainId, 0, inst.splitedHeightmapList.Count - 1);

                if (GUILayout.Button("Update Terrain Tile"))
                {
                    //GenerateTerrainById(inst.generatedTerrainList, inst.splitedHeightmapList, inst.updateTerrainId);
                    GenerateTerrainTile(inst.generatedTerrainList, inst.splitedHeightmapList, inst.updateTerrainTile);
                }
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.EndVertical();
            }
            EditorGUI.EndDisabledGroup();
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

                if (item.terrainData)
                {
                    item.terrainData.terrainLayers = inst.terrainLayers;
                }
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
                        inst.splitedControlMaps = TextureTools.SplitTextures(inst.controlMaps, inst.controlMapResolution, ref inst.controlMapCountInRow,(progress)=> {
                            EditorUtility.DisplayProgressBar("Spliat ControlMaps", "Spliat ControlMaps", progress);
                        });
                        EditorUtility.ClearProgressBar();
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

        void GenerateTerrainTile(List<Terrain> terrains,List<Texture2D> heightmaps,Terrain terrain)
        {
            if (!terrain)
                return;

            var id = terrains.FindIndex((t) => t == terrain);
            if (id < 0 || id >= terrains.Count)
                return;
            GenerateTerrainById(terrains, heightmaps, id);
        }

    }
}
#endif
