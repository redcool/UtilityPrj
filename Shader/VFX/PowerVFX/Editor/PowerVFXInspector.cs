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
        Dictionary<string, string> i18nDict = new Dictionary<string, string>();

        int selectedId;
        bool showOriginalPage;

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

            selectedId = ConfigTool.EditorSelectedId;
            selectedId = GUILayout.Toolbar(selectedId, tabNames);
            ConfigTool.EditorSelectedId = selectedId;

            EditorGUILayout.EndHorizontal();

            var propNames = propNameList[selectedId];
            foreach (var propName in propNames)
            {
                if (!propDict.ContainsKey(propName))
                    continue;

                var prop = propDict[propName];
                materialEditor.ShaderProperty(prop, ConfigTool.Text(prop.name));
            }
            EditorGUILayout.EndVertical();
        }

    }

    public static class ConfigTool
    {
        static Dictionary<string, string> propNameValuedict = new Dictionary<string, string>();

        static Dictionary<string, MaterialProperty> propDict = new Dictionary<string, MaterialProperty>();

        public static void Reset()
        {
            propNameValuedict.Clear();
            propDict.Clear();
        }

        static string FindI18NPath(string configPath)
        {
            var pathDir = Path.GetDirectoryName(configPath);
            var filePath = "";
            var findCount = 0;
            while (!pathDir.EndsWith("Assets"))
            {
                filePath = pathDir + "/i18n.txt";
                pathDir = Path.GetDirectoryName(pathDir);
                if (File.Exists(filePath) || ++findCount > 10)
                    break;
            }
            return filePath;
        }

        public static void ReadConfig(string configPath)
        {
            if (propNameValuedict.Count > 0)
                return;

            var splitRegex = new Regex(@"\s*=\s*");
            var filePath = FindI18NPath(configPath);

            if (!string.IsNullOrEmpty(filePath))
            {
                var lines = File.ReadAllLines(filePath);
                foreach (var lineStr in lines)
                {
                    var line = lineStr.Trim();
                    if (string.IsNullOrEmpty(line) || line.StartsWith("//"))
                        continue;

                    var kv = splitRegex.Split(line);
                    if (kv.Length > 1)
                        propNameValuedict[kv[0]] = kv[1];
                }
            }

        }

        public static void ReadConfig(Shader shader)
        {
            var path = AssetDatabase.GetAssetPath(shader);
            ReadConfig(path);
        }

        public static Dictionary<string, MaterialProperty> CacheProperties(MaterialProperty[] properties)
        {
            if (propDict.Count > 0)
                return propDict;

            foreach (var prop in properties)
            {
                propDict[prop.name] = prop;
            }

            return propDict;
        }

        public static string Text(string str)
        {
            string text = str;
            if (propNameValuedict.ContainsKey(str))
                text = propNameValuedict[str];

            return text;
        }

        public static int EditorSelectedId
        {
            get { return EditorPrefs.GetInt("ConfigTool_SelectedId"); }
            set { EditorPrefs.SetInt("ConfigTool_SelectedId",value); }
        }
    }
}
#endif