﻿#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using System.Linq;
using System;

namespace PowerVFX
{
    //UnityEngine.Rendering.BlendMode
    public enum PresetBlendMode
    {
        AlphaBlend,
        SoftAdd, 
        Add,
        PremultiTransparent,
        MultiColor,
        MultiColor_2X
    }

    public class PowerVFXInspector : ShaderGUI
    {
        const string SRC_MODE = "_SrcMode", DST_MODE = "_DstMode";
        const string POWER_VFX_SHADER = "PowerVFX";

        static string[] tabNames = new[] {"Settings", "Main", "Distortion", "Dissovle", "Offset", "Fresnal","EnvReflect","MatCap"};
        static List<string[]> propNameList = new List<string[]> {
            new []{ "_DoubleEffectOn", "_CullMode", "_ZWriteMode"},
            new []{ "_MainTex", "_MainTexOffsetStop", "_MainTexOffsetUseCustomData_XY", "_Color","_ColorScale", "_MainTexMask","_MainTexMaskOffsetStop","_MainTexMaskUseR" ,"_MainTexUseScreenColor"},
            new []{ "_DistortionOn", "_NoiseTex","_NoiseTex2", "_DistortionMaskTex", "_DistortionMaskUseR", "_DistortionIntensity", "_DistortTile", "_DistortDir",},
            new []{ "_DissolveOn","_DissolveRevert", "_DissolveTex","_DissolveTexOffsetStop", "_DissolveTexUseR", "_DissolveByVertexColor", "_DissolveByCustomData", "_Cutoff", "_DissolveEdgeOn","_DissolveEdgeWidthBy_Custom1", "_EdgeWidth", "_EdgeColor","_EdgeColorIntensity"},
            new []{ "_OffsetOn", "_OffsetTex", "_OffsetMaskTex", "_OffsetMaskTexUseR", "_OffsetTexColorTint", "_OffsetTexColorTint2", "_OffsetTile", "_OffsetDir", "_BlendIntensity", "_OffsetHeightMap", "_OffsetHeight"},
            new []{ "_FresnalOn", "_FresnalColor", "_FresnalPower", "_FresnalTransparentOn","_FresnalTransparent" },
            new []{ "_EnvReflectOn", "_EnvMap","_EnvMapMask", "_EnvMapMaskUseR", "_EnvIntensity" ,"_EnvOffset"},
            new []{ "_MatCapTex", "_MatCapIntensity"}
        };

        int selectedTabId;
        bool showOriginalPage;

        const string POWERVFX_SELETECTED_ID = "PowerVFX_SeletectedId";
        const int SETTING_TAB_ID = 0; // preset blend mode 显示在 0 号tab页

        Dictionary<PresetBlendMode, BlendMode[]> blendModeDict;
        Dictionary<string, MaterialProperty> propDict;
        Dictionary<string, string> propNameTextDict;

        bool isFirstRunOnGUI = true;
        string helpStr;
        string[] tabNamesInConfig;
        Shader lastShader;

        MaterialEditor materialEditor;
        MaterialProperty[] materialProperties;
        PresetBlendMode presetBlendMode;
        int languageId;

        public PowerVFXInspector()
        {
            blendModeDict = new Dictionary<PresetBlendMode, BlendMode[]> {
                {PresetBlendMode.AlphaBlend,new []{ BlendMode.SrcAlpha,BlendMode.OneMinusSrcAlpha} },
                {PresetBlendMode.SoftAdd,new []{ BlendMode.SrcAlpha, BlendMode.One} }, //OneMinusDstColor
                {PresetBlendMode.Add,new []{ BlendMode.One,BlendMode.One} },
                {PresetBlendMode.PremultiTransparent,new []{BlendMode.One,BlendMode.OneMinusSrcAlpha } },
                {PresetBlendMode.MultiColor,new []{ BlendMode.DstColor,BlendMode.Zero} },
                {PresetBlendMode.MultiColor_2X,new []{ BlendMode.DstColor,BlendMode.SrcColor} },
            };
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.materialEditor = materialEditor;
            materialProperties = properties;

            var mat = materialEditor.target as Material;
            propDict = ConfigTool.CacheProperties(properties);

            if (isFirstRunOnGUI || lastShader != mat.shader)
            {
                lastShader = mat.shader;

                isFirstRunOnGUI = false;
                OnInit(mat, properties);
            }
            // title
            EditorGUILayout.HelpBox(helpStr, MessageType.Info);

            //show original
            showOriginalPage = GUILayout.Toggle(showOriginalPage, ConfigTool.Text(propNameTextDict, "ShowOriginalPage"));
            if (showOriginalPage)
            {
                base.OnGUI(materialEditor, properties);
                return;
            }

            EditorGUILayout.BeginVertical("Box");
            {
                DrawPageTabs();

                EditorGUILayout.BeginVertical("Box");
                DrawPageDetail(materialEditor, mat);
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndVertical();
        }

        /// <summary>
        /// draw properties
        /// </summary>
        private void DrawPageDetail(MaterialEditor materialEditor, Material mat)
        {
            var propNames = propNameList[selectedTabId];
            foreach (var propName in propNames)
            {
                if (!propDict.ContainsKey(propName))
                    continue;

                var prop = propDict[propName];
                materialEditor.ShaderProperty(prop, ConfigTool.Text(propNameTextDict, prop.name));
            }

            if (selectedTabId == SETTING_TAB_ID && IsPowerVFXShader(mat))
            {
                DrawBlendMode(mat);
            }
        }

        private static bool IsPowerVFXShader(Material mat)
        {
            return mat.shader.name.Contains(POWER_VFX_SHADER);
        }

        private void DrawPageTabs()
        {
            //cache selectedId
            selectedTabId = EditorPrefs.GetInt(POWERVFX_SELETECTED_ID, selectedTabId);
            selectedTabId = GUILayout.Toolbar(selectedTabId, tabNamesInConfig);
            EditorPrefs.SetInt(POWERVFX_SELETECTED_ID, selectedTabId);
        }

        private void OnInit(Material mat,MaterialProperty[] properties)
        {
            if(IsPowerVFXShader(mat))
                presetBlendMode = GetPresetBlendMode(mat);

            var shaderFilePath = AssetDatabase.GetAssetPath(mat.shader);
            SetupLayout(shaderFilePath);

            propNameTextDict = ConfigTool.ReadI18NConfig(shaderFilePath);

            helpStr = ConfigTool.Text(propNameTextDict,"Help").Replace('|','\n');

            tabNamesInConfig = tabNames.Select(item => ConfigTool.Text(propNameTextDict, item)).ToArray();
        }

        private void SetupLayout(string shaderFilePath)
        {
            var layoutConfigPath = ConfigTool.FindPathRecursive(shaderFilePath, "PowerVFXLayout.txt");
            var dict = ConfigTool.ReadKeyValueConfig(layoutConfigPath);

            if (!dict.TryGetValue("tabNames", out var tabNamesLine))
                return;

            // for tabNames
            tabNames = ConfigTool.SplitBy(tabNamesLine);

            // for tab contents
            propNameList.Clear();
            for (int i = 0; i < tabNames.Length; i++)
            {
                var tabName = tabNames[i];
                var propNamesLine = dict[tabName];
                var propNames = ConfigTool.SplitBy(propNamesLine);
                propNameList.Add(propNames);
            }
        }

        void DrawBlendMode(Material mat)
        {
            EditorGUI.BeginChangeCheck();
            presetBlendMode = (PresetBlendMode)EditorGUILayout.EnumPopup(ConfigTool.Text(propNameTextDict,"PresetBlendMode"), presetBlendMode);
            if (EditorGUI.EndChangeCheck())
            {
                var blendModes = blendModeDict[presetBlendMode];

                mat.SetFloat(SRC_MODE, (int)blendModes[0]);
                mat.SetFloat(DST_MODE, (int)blendModes[1]);
            }
        }

        PresetBlendMode GetPresetBlendMode(BlendMode srcMode, BlendMode dstMode)
        {
            return blendModeDict.Where(kv => kv.Value[0] == srcMode && kv.Value[1] == dstMode).FirstOrDefault().Key;
        }

        PresetBlendMode GetPresetBlendMode(Material mat)
        {
            var srcMode = mat.GetInt(SRC_MODE);
            var dstMode = mat.GetInt(DST_MODE);
            return GetPresetBlendMode((BlendMode)srcMode, (BlendMode)dstMode);
        }
    }
}


#endif