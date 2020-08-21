#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class WeatherSpecTerrainInspector : WeatherInspector
{
    public WeatherSpecTerrainInspector()
    {
        weatherSelectedIdKeyName = "WeatherSpecTerrainSelectedId";
        weatherRainSelectedIdKeyName = "WeatherSpecTerrainRainSelectedId";

        tabNames = new[] { "Main", "CustomLight", "Snow", "Rain", };

        propNameList = new List<List<string>> {
                new List<string> {
                    "_NormalMapOn","_RealtimeBaseNormal",
                    "_Splat0","_BumpSplat0","_NormalRange","_ShininessL0","_GlossIntensity0",
                    "_Splat1","_BumpSplat1","_NormalRange1","_ShininessL1","_GlossIntensity1",
                    "_Splat2","_BumpSplat2","_NormalRange2","_ShininessL2","_GlossIntensity2",
                    "_Splat3","_BumpSplat3","_NormalRange3","_ShininessL3","_GlossIntensity3",
                    "_Tiling3","_Control","_MainTex"
                },
                new List<string> {"_SpecDir","_SpecColor","_CustomLightOn","_LightDir","_LightColor"},
                new List<string>{
                    "_DisableSnowDir","_DefaultSnowRate","_SnowNoiseMapOn","_SnowNoiseMap","_NoiseDistortNormalIntensity",
                    "_SnowDirection","_SnowColor","_SnowAngleIntensity","_SnowTile","_BorderWidth","_ToneMapping",
                },
                new List<string>{ },
            };

        // rain 
        rainTabId = 3;
        rainTabNames = new[] { "Rain Specular", "SurfaceWave", "EnvReflection", "Ripple", };
        rainPropNameList = new List<List<string>>
            {
                new List<string> {"_RainSpecDir","_RainSpecColor","_RainTerrainShininess"},
                new List<string>{"_WaveColor","_Tile","_Direction","_WaveNoiseMap","_WaveBorderWidth","_DirAngle","_WaveIntensity","_WaveLayerIntensity"},
                new List<string>{ "_EnvTex","_EnvColor","_EnvNoiseMap","_EnvIntensity","_EnvTileOffset","_EnvLayerIntensity",},
                new List<string>{"_RippleOn","_RippleTex","_RippleScale","_RippleIntensity","_RippleColorTint","_RippleSpeed" ,"_WaveLayerIntensity"},
            };
        showPresetBlendMode = false;
    }
}
#endif