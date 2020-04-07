#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace PowerVFX
{
    //UnityEngine.Rendering.BlendMode
    public enum PresetBlendMode
    {
        AlphaBlend,//src=5,dst=10
        SoftAdd, // src=5,dst=1
    }
    public class PowerVFXInspector : ShaderGUI
    {

        static string[] tabNames = new[] { "Main", "Distortion", "Dissovle", "Offset", };
        static List<string[]> propNameList = new List<string[]> {
            new []{ "_MainTex", "_MainTexOffsetStop", "_Color", "_DoubleEffectOn", "_CullMode", },
            new []{ "_DistortionOn", "_NoiseTex", "_DistortionMaskTex", "_DistortionIntensity", "_DistortTile", "_DistortDir",},
            new []{ "_DissolveOn", "_DissolveTex", "_DissolveTexUseR", "_DissolveByVertexColor", "_Cutoff", "_DissolveEdgeOn", "_EdgeColor", "_EdgeWidth",},
            new []{ "_OffsetOn", "_OffsetTex", "_OffsetMaskTex", "_OffsetTexColorTint", "_OffsetTile", "_OffsetDir", "_BlendIntensity", }
        };
        //Dictionary<string, string> i18nDict = new Dictionary<string, string>();

        int selectedId;
        bool showOriginalPage;

        const string POWERVFX_SELETECTED_ID = "PowerVFX_SeletectedId";

        PresetBlendMode presetBlendMode;

        public PowerVFXInspector()
        {
            ConfigTool.Reset();
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
        }

        void DrawBlendMode(Material mat)
        {
            EditorGUI.BeginChangeCheck();
            presetBlendMode = (PresetBlendMode)EditorGUILayout.EnumPopup(ConfigTool.Text("PresetBlendMode"), presetBlendMode);
            if (EditorGUI.EndChangeCheck())
            {
                var src = 5;
                var dst = 10;
                if (presetBlendMode == PresetBlendMode.SoftAdd)
                    dst = 1;

                mat.SetFloat("_SrcMode", src);
                mat.SetFloat("_DstMode", dst);
            }
        }
    }
}


#endif