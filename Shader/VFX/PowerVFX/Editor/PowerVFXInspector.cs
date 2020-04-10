#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using System.Linq;

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
        static string[] tabNames = new[] { "Main", "Distortion", "Dissovle", "Offset", "Fresnal",};
        static List<string[]> propNameList = new List<string[]> {
            new []{ "_MainTex", "_MainTexOffsetStop", "_Color","_ColorScale", "_DoubleEffectOn", "_CullMode", },
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

        bool isFirstRunOnGUI = true;

        public PowerVFXInspector()
        {
            ConfigTool.Reset();

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
            // title
            EditorGUILayout.HelpBox("PowerVFX", MessageType.Info);

            //show original
            showOriginalPage = GUILayout.Toggle(showOriginalPage, ConfigTool.Text("ShowOriginalPage"));
            if (showOriginalPage)
            {
                base.OnGUI(materialEditor, properties);
                return;
            }
            // setup infos
            var propDict = ConfigTool.CacheProperties(properties);

            var mat = materialEditor.target as Material;
            ConfigTool.ReadConfig(mat.shader);

            //draw properties
            EditorGUILayout.BeginVertical("Box");

            EditorGUILayout.BeginHorizontal("Box");
            //cache selectedId
            selectedId = EditorPrefs.GetInt(POWERVFX_SELETECTED_ID, selectedId);
            selectedId = GUILayout.Toolbar(selectedId, tabNames);
            EditorPrefs.SetInt(POWERVFX_SELETECTED_ID, selectedId);

            EditorGUILayout.EndHorizontal();

            var propNames = propNameList[selectedId];
            foreach (var propName in propNames)
            {
                if (!propDict.ContainsKey(propName))
                    continue;

                var prop = propDict[propName];
                materialEditor.ShaderProperty(prop, ConfigTool.Text(prop.name));
            }
            if (selectedId == 0 && mat.shader.name.EndsWith("PowerVFXShader"))
                DrawBlendMode(mat);
            EditorGUILayout.EndVertical();

            isFirstRunOnGUI = false;
        }

        void DrawBlendMode(Material mat)
        {
            const string SRC_MODE = "_SrcMode", DST_MODE = "_DstMode";

            if (isFirstRunOnGUI)
            {
                SetupPresetBlendMode(mat, SRC_MODE, DST_MODE);
            }

            EditorGUI.BeginChangeCheck();
            presetBlendMode = (PresetBlendMode)EditorGUILayout.EnumPopup(ConfigTool.Text("PresetBlendMode"), presetBlendMode);
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

        private void SetupPresetBlendMode(Material mat, string SRC_MODE, string DST_MODE)
        {
            var srcMode = mat.GetInt(SRC_MODE);
            var dstMode = mat.GetInt(DST_MODE);
            var lastPresetBlendMode = GetPresetBlendMode((BlendMode)srcMode, (BlendMode)dstMode);
            presetBlendMode = lastPresetBlendMode;
        }
    }
}


#endif