#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using System.Linq;
using ConfigTool = PowerVFX.ConfigTool;
using UnityEngine.Rendering;

public class WeatherInspector : ShaderGUI
{
    public enum PresetBlendMode
    {
        Geometry,Transparent,Additive,AlphaTest
    }

    public class PresetBlendModeInfo
    {
        public int srcMode = 1,dstMode = 0;
        public int renderQueue = 2000;
        public int zWrite = 1;
    }
    /// <summary>
    /// 全部的类别名
    /// </summary>
    protected string[] tabNames = new[] { "Main", "CustomLight", "Snow", "Rain", "Wind"};

    protected List<List<string>> propNameList = new List<List<string>> {
            new List<string>{"_MainTex","_Color","_BumpMap", "_NormalMapScale",
                "_AlphaTestOn", "_Cutoff", "_ZWrite",
                "_Illum", "_IllumColor", "_EmissionScale",
                "_DisableWeather"
            },
            new List<string>{"_CustomLightOn","_LightDir", "_LightColor", "_LightmapScale", "_SpecColor","_SpecIntensity","_Gloss"},
            new List<string>{
                "_DisableSnowDir","_DefaultSnowRate","_SnowNoiseMapOn","_SnowNoiseMap","_NoiseDistortNormalIntensity",
                "_SnowDirection","_SnowColor","_SnowAngleIntensity","_SnowTile","_BorderWidth","_ToneMapping",
            },
            new List<string>{ },
            new List<string>{ "_Plants_Off", "_ExpandBillboard","_Wave","_Wind","_AttenField",  }//"_WorldPos", "_WorldScale"
        };

    // rain tab
    protected string[] rainTabNames = new[] { "SurfaceWave", "EvnReflection", "Ripple", };
    protected List<List<string>> rainPropNameList = new List<List<string>>
        {
            new List<string>{"_WaveColor","_Tile","_Direction","_WaveNoiseMap","_WaveBorderWidth","_DirAngle","_WaveIntensity",},
            new List<string>{ "_EnvTex","_EnvColor","_EnvNoiseMap","_EnvIntensity","_EnvTileOffset",},
            new List<string>{"_RippleOn","_RippleTex","_RippleScale","_RippleIntensity","_RippleColorTint","_RippleSpeed" },
        };
    protected int rainTabId = 3;

    protected string weatherSelectedIdKeyName = "weatherSelectedId";
    protected string weatherRainSelectedIdKeyName = "weatherRainSelectedId";
    string DISABLE_WEATHER = "_DisableWeather";

    bool showOriginalPage;

    protected int selectedId;
    protected int rainSelectedId;

    protected Dictionary<string, MaterialProperty> propDict;
    protected Dictionary<string, string> propNameTextDict;//{key,tex}
    protected bool showPresetBlendMode = true;

    bool isRunFirst = true;

    /// <summary>
    /// Preset Blend Mode
    /// </summary>
    private PresetBlendMode presetBlendMode;
    private Dictionary<PresetBlendMode, PresetBlendModeInfo> presetBlendModeDict = new Dictionary<PresetBlendMode, PresetBlendModeInfo>{
        {PresetBlendMode.Geometry,new PresetBlendModeInfo{srcMode = 1,dstMode=0} },
        {PresetBlendMode.Transparent, new PresetBlendModeInfo{ srcMode = (int)BlendMode.SrcAlpha,dstMode=(int)BlendMode.OneMinusSrcAlpha,renderQueue=3000,zWrite=0} },
        {PresetBlendMode.Additive,new PresetBlendModeInfo{srcMode=1,dstMode=1,renderQueue=3000,zWrite=0 } },
        {PresetBlendMode.AlphaTest,new PresetBlendModeInfo{srcMode = 1,dstMode=0,renderQueue = (int)RenderQueue.AlphaTest } }
    };

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        var mat = materialEditor.target as Material;

        propDict = ConfigTool.CacheProperties(properties);

        if (isRunFirst)
        {
            isRunFirst = false;
            OnInit(mat, properties);
        }
        EditorGUILayout.HelpBox("WeatherProcess", MessageType.Info);

        showOriginalPage = GUILayout.Toggle(showOriginalPage, ConfigTool.Text(propNameTextDict, "ShowOriginalPage"));
        if (showOriginalPage)
        {
            base.OnGUI(materialEditor, properties);
            return;
        }

        // show tabs
        ShowAllTabs();

        //filter properties
        List<string> propNames = FilterPropNames();

        //draw filtered properties
        DrawFilteredProperties(materialEditor, propDict, propNames);

        //draw alpha blend
        if(showPresetBlendMode)
            DrawAlphaBlend(mat);
    }

    void DrawAlphaBlend(Material mat)
    {
        if (selectedId != 0)
            return;
        presetBlendMode = (PresetBlendMode)mat.GetInt("_PresetBlendMode");

        EditorGUILayout.PrefixLabel("Alpha Blend");

        EditorGUI.BeginChangeCheck();
        presetBlendMode = (PresetBlendMode)EditorGUILayout.EnumPopup(ConfigTool.Text(propNameTextDict, "PresetBlendMode"), presetBlendMode);
        if (EditorGUI.EndChangeCheck())
        {
            SetAlphaMode(mat, presetBlendMode);
        }
        else // check default mode
        {
            if (presetBlendMode == PresetBlendMode.Geometry)
            {
                SetAlphaMode(mat, PresetBlendMode.Geometry);
            }
        }
    }

    private void SetAlphaMode(Material mat, PresetBlendMode presetBlendMode)
    {
        var info = presetBlendModeDict[presetBlendMode];
        mat.SetFloat("_SrcBlend", info.srcMode);
        mat.SetFloat("_DstBlend", info.dstMode);

        // update queue
        mat.renderQueue = info.renderQueue;
        // update zwrite
        mat.SetFloat("_ZWrite", info.zWrite);
        mat.SetInt("_PresetBlendMode", (int)presetBlendMode);
    }

    protected virtual void OnInit(Material mat, MaterialProperty[] properties)
    {

        propNameTextDict = ConfigTool.ReadConfig(mat.shader);

        //关闭天气效果
        if (propDict.ContainsKey(DISABLE_WEATHER) && propDict[DISABLE_WEATHER].floatValue == 1 && !mat.IsKeywordEnabled("_FEATURE_NONE"))
        {
            mat.DisableKeyword("_FEATURE_SNOW");
            mat.DisableKeyword("_FEATURE_SURFACE_WAVE");
            mat.EnableKeyword("_FEATURE_NONE");
        }
    }

    private void DrawFilteredProperties(MaterialEditor materialEditor, Dictionary<string, MaterialProperty> propDict, List<string> propNames)
    {
        GUI.backgroundColor = Color.white;
        foreach (var propName in propNames)
        {
            if (!propDict.ContainsKey(propName))
                continue;
            var prop = propDict[propName];
            materialEditor.ShaderProperty(prop, ConfigTool.Text(propNameTextDict, propName));
        }
    }

    private void ShowAllTabs()
    {
        ShowTabs(tabNames, ref selectedId, weatherSelectedIdKeyName);

        // show rain tabs
        if (selectedId == rainTabId)
        {
            GUI.backgroundColor = new Color(.2f, .4f, .02f);
            ShowTabs(rainTabNames, ref rainSelectedId, weatherRainSelectedIdKeyName);
        }
    }

    private List<string> FilterPropNames()
    {
        if (selectedId >= propNameList.Count)
            selectedId = 0;

        var propNames = propNameList[selectedId];
        // rain tab
        if (selectedId == rainTabId)
        {
            if (rainSelectedId >= rainPropNameList.Count)
                rainSelectedId = 0;

            propNames = rainPropNameList[rainSelectedId];
        }

        return propNames;
    }

    void ShowTabs(string[] tabNames, ref int selectedId, string seletecdIdPrefKey)
    {
        selectedId = EditorPrefs.GetInt(seletecdIdPrefKey, selectedId);
        selectedId = GUILayout.Toolbar(selectedId, tabNames);
        EditorPrefs.SetInt(seletecdIdPrefKey, selectedId);
    }

}

#endif