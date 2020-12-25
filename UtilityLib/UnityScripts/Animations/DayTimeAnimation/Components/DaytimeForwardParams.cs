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
    public float fogEndDistance=100;
    public float fogStartDistance=10;
    public bool fogEnabled;
    public Color fogColor = Color.gray;

    [Header("Furniature Light Control")]
    public bool isFurnitureLightControlOn;
    public float furnitureLightIntensity = 1;


    // Start is called before the first frame update
    void Start()
    {
        if (!HeightFogSetting.Instance)
        {
            Shader.SetGlobalInt(WeatherShader.IS_HEIGHT_FOG_ON, 0);
        }
    }

    // Update is called once per frame
    void Update()
    {
        RenderSettings.ambientSkyColor = ambientColor;

        UpdateFog();

        Shader.SetGlobalInt("_FurnitureLightControlOn", isFurnitureLightControlOn ? 1 : 0);
        Shader.SetGlobalFloat("_FurnitureLightIntensity", furnitureLightIntensity);
    }

    private void UpdateFog()
    {
        if (isUpdateFog)
        {
            RenderSettings.fogEndDistance = fogEndDistance;
            RenderSettings.fogStartDistance = fogStartDistance;
            RenderSettings.fog = fogEnabled;
            RenderSettings.fogColor = fogColor;

            Shader.SetGlobalInt(WeatherShader.IS_FOG_ON, fogEnabled ? 1 : 0);
        }
    }

    private void OnDestroy()
    {
        Shader.SetGlobalInt("_FurnitureLightControlOn", 0);
    }
}
