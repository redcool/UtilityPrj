#if UNITY_EDITOR
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

        static string[] tabNames = new[] {"Settings", "Main", "Distortion", "Dissovle", "Offset", "Fresnal",};
        static List<string[]> propNameList = new List<string[]> {
            new []{ "_DoubleEffectOn", "_CullMode", },
            new []{ "_MainTex", "_MainTexOffsetStop", "_Color","_ColorScale", "_MainTexMask","_MainTexMask_R_A" },
            new []{ "_DistortionOn", "_NoiseTex", "_DistortionMaskTex", "_DistortionIntensity", "_DistortTile", "_DistortDir",},
            new []{ "_DissolveOn", "_DissolveTex", "_DissolveTexUseR", "_DissolveByVertexColor", "_DissolveByCustomData", "_Cutoff", "_DissolveEdgeOn", "_EdgeColor", "_EdgeWidth",},
            new []{ "_OffsetOn", "_OffsetTex", "_OffsetMaskTex", "_OffsetTexColorTint", "_OffsetTile", "_OffsetDir", "_BlendIntensity", },
            new []{ "_FresnalOn", "_FresnalColor", "_FresnalPower", "_FresnalTransparentOn" },
        };

        int selectedId;
        bool showOriginalPage;

        const string POWERVFX_SELETECTED_ID = "PowerVFX_SeletectedId";

        PresetBlendMode presetBlendMode;
        Dictionary<PresetBlendMode, BlendMode[]> blendModeDict;
        Dictionary<string, MaterialProperty> propDict;
        Dictionary<string, string> propNameTextDict;

        bool isFirstRunOnGUI = true;

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
            var mat = materialEditor.target as Material;

            if (isFirstRunOnGUI)
            {
                isFirstRunOnGUI = false;
                OnInit(mat, properties);
            }
            // title
            EditorGUILayout.HelpBox("PowerVFX", MessageType.Info);

            //show original
            showOriginalPage = GUILayout.Toggle(showOriginalPage, ConfigTool.Text(propNameTextDict, "ShowOriginalPage"));
            if (showOriginalPage)
            {
                base.OnGUI(materialEditor, properties);
                return;
            }

            
            EditorGUILayout.BeginVertical("Box");
            DrawPageTabs();
            DrawPageDetail(materialEditor, mat);
            EditorGUILayout.EndVertical();
        }

        /// <summary>
        /// draw properties
        /// </summary>
        private void DrawPageDetail(MaterialEditor materialEditor, Material mat)
        {
            var propNames = propNameList[selectedId];
            foreach (var propName in propNames)
            {
                if (!propDict.ContainsKey(propName))
                    continue;

                var prop = propDict[propName];
                materialEditor.ShaderProperty(prop, ConfigTool.Text(propNameTextDict, prop.name));
            }
            if (selectedId == 0 && mat.shader.name.EndsWith("PowerVFXShader"))
                DrawBlendMode(mat);
        }


        private void DrawPageTabs()
        {
            EditorGUILayout.BeginHorizontal("Box");
            //cache selectedId
            selectedId = EditorPrefs.GetInt(POWERVFX_SELETECTED_ID, selectedId);
            selectedId = GUILayout.Toolbar(selectedId, tabNames);
            EditorPrefs.SetInt(POWERVFX_SELETECTED_ID, selectedId);
            EditorGUILayout.EndHorizontal();
        }

        private void OnInit(Material mat,MaterialProperty[] properties)
        {
            presetBlendMode = GetPresetBlendMode(mat);
            propNameTextDict = ConfigTool.ReadConfig(mat.shader);
            propDict = ConfigTool.CacheProperties(properties);
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