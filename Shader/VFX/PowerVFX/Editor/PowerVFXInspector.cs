#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace PowerVFX
{

    public class PowerVFXInspector : ShaderGUI
    {
        static string[] tabNames = new[] { "Main", "Distortion", "Dissovle", "Offset", };
        static List<string[]> propNameList = new List<string[]> {
            new []{ "_MainTex", "_MainTexOffsetOn", "_Color", "_DoubleEffectOn", "_CullMode", },
            new []{ "_DistortionOn", "_NoiseTex", "_DistortionMaskTex", "_DistortionIntensity", "_DistortTile", "_DistortDir",},
            new []{ "_DissolveOn", "_DissolveTex", "_DissolveTexUseR", "_DissolveByVertexColor", "_Cutoff", "_DissolveEdgeOn", "_EdgeColor", "_EdgeWidth",},
            new []{ "_OffsetOn", "_OffsetTex", "_OffsetMaskTex", "_OffsetTexColorTint", "_OffsetTile", "_OffsetDir", "_BlendIntensity", }
        };
        Dictionary<string,string> i18nDict = new Dictionary<string, string>();

        int selectedId;
        Dictionary<string, MaterialProperty> propDict;
        bool showOriginalPage;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            // title
            EditorGUILayout.HelpBox("PowerVFX", MessageType.Info);

            //show original
            showOriginalPage = GUILayout.Toggle(showOriginalPage, Text("ShowOriginalPage"));
            if (showOriginalPage)
            {
                base.OnGUI(materialEditor, properties);
                return;
            }
            // setup infos
            CacheProperties(properties);

            var mat = materialEditor.target as Material;
            SetupI18N(i18nDict,mat.shader);

            //draw properties
            EditorGUILayout.BeginVertical("Box");

            EditorGUILayout.BeginHorizontal("Box");
            selectedId = GUILayout.Toolbar(selectedId, tabNames);
            EditorGUILayout.EndHorizontal();

            var propNames = propNameList[selectedId];
            foreach (var propName in propNames)
            {
                var prop = propDict[propName];
                materialEditor.ShaderProperty(prop,Text(prop.name));
            }
            EditorGUILayout.EndVertical();
        }


        void CacheProperties(MaterialProperty[] properties)
        {
            if (propDict != null)
                return;

            propDict = new Dictionary<string, MaterialProperty>();

            foreach (var prop in properties)
            {
                propDict[prop.name] = prop;
            }
        }

        static void SetupI18N(Dictionary<string,string> dict,Shader shader)
        {
            if (dict.Count > 0)
                return;

            var splitRegex = new Regex(@"\s*=\s*");
            
            var path = AssetDatabase.GetAssetPath(shader);
            var pathDir = Path.GetDirectoryName(path);
            var fileParth = pathDir + "/i18n.txt";
            if (File.Exists(fileParth))
            {
                var lines = File.ReadAllLines(fileParth);
                foreach (var lineStr in lines)
                {
                    var line = lineStr.Trim();
                    if (string.IsNullOrEmpty(line) || line.StartsWith("//"))
                        continue;

                    var kv = splitRegex.Split(line);
                    dict[kv[0]] = kv[1];
                }
            }
        }

        string Text(string str)
        {
            string text = str;
            if (i18nDict.ContainsKey(str))
                text = i18nDict[str];

            return text;
        }
    }
}
#endif