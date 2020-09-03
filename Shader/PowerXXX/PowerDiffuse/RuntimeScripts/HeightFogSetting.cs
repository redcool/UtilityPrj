using UnityEngine;

[ExecuteInEditMode]
public class HeightFogSetting : MonoBehaviour
{
    public static HeightFogSetting Instance { private set; get; }

    [Header("Height Fog")]
    public float min = 0;
    public float max = 100;
    public Color heightFogColor = new Color(0,0,0.2f);

    [Header("Fog")]
    public float near = 25;
    public float far = 100;
    public Color gloabFogColor = new Color(0,0,0.3f);

    [Header("Fast SSS")]
    public Color sunFogColor = new Color(0.2f,0.5f,0.3f);
    [Range(1, 10)]public float sunFogLight = 1;
    public Vector3 sunFogDir = new Vector3(0,0.5f,0);
    void Awake()
    {
        ApplyHeightFogSet();
        Instance = this;
    }
#if UNITY_EDITOR
    void Update()
    {
        ApplyHeightFogSet();
    }
#endif

    public void ApplyHeightFogSet()
    {
        if (max < min)
            max = min;
        if (far < near)
            far = near;

        Shader.SetGlobalFloat("_HeightFogMin", min);
        Shader.SetGlobalFloat("_HeightFogMax", max);

        Shader.SetGlobalFloat("_HeightFogNear", RenderSettings.fogStartDistance);
        Shader.SetGlobalFloat("_HeightFogFar", RenderSettings.fogEndDistance);

        Shader.SetGlobalColor("_sunFogColor", sunFogColor * sunFogLight);
        Shader.SetGlobalColor("_HeightFogColor", heightFogColor);
        Shader.SetGlobalVector("_SunFogDir", sunFogDir);

        RenderSettings.fogColor = gloabFogColor;
        RenderSettings.fogStartDistance = near;
        RenderSettings.fogEndDistance = far;
    }

    public void UpdateFog(float start,float end,float heightMin,float heightMax,Color fogColor,Color heightFogColor,Color sunFogColor)
    {
        near = start;
        far = end;
        min = heightMin;
        max = heightMax;
        this.gloabFogColor = fogColor;
        this.heightFogColor = heightFogColor;
        this.sunFogColor = sunFogColor;

        ApplyHeightFogSet();
    }
}
