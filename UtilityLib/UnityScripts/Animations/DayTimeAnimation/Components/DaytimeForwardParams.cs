using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// DaytimeAnimation 间接控制的unity属性
/// 比如 RenderSettings的属性
/// </summary>
[ExecuteInEditMode]
public class DaytimeForwardParams : MonoBehaviour
{
    [Header("RenderSettings")]
    public Color ambientColor = Color.gray;

    [Header("Fog")]
    public bool isUpdateFog;
    public bool fogEnabled;
    public Color fogColor = Color.gray;
    public FogMode fogMode = FogMode.Linear;

    [Header("Linear Fog")]
    public float fogEndDistance=100;
    public float fogStartDistance=10;

    [Header("Exp Fog")]
    public float fogDentisy = 0.01f;

    // Update is called once per frame
    void Update()
    {
        RenderSettings.ambientSkyColor = ambientColor;

        UpdateFog();
    }

    void EnableFog(bool isEnalbed)
    {
        RenderSettings.fog = isEnalbed;
        //Shader.SetGlobalInt(WeatherShader.IS_FOG_ON, fogEnabled ? 1 : 0);
    }

    private void UpdateFog()
    {
        if (isUpdateFog)
        {
            RenderSettings.fogEndDistance = fogEndDistance;
            RenderSettings.fogStartDistance = fogStartDistance;
            EnableFog(fogEnabled);

            RenderSettings.fogColor = fogColor;
            RenderSettings.fogMode = fogMode;
            RenderSettings.fogDensity = fogDentisy;
        }
    }

}
