using UnityEngine;

[ExecuteInEditMode]
public class HeightFogSetting : MonoBehaviour
{
    public float min;
    public float max;
    public float near;
    public float far;
    public Color sunFogColor;
    public Color heightFogColor;
    public Color gloabFogColor;
    [Range(1, 10)]
    public float sunFogLight = 1;
  
   public Vector3 _SunFogDir;
    void Awake()
    {
        ApplyHeightFogSet();
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
        Shader.SetGlobalFloat("_HeightFogNear", near);
        Shader.SetGlobalFloat("_HeightFogFar", far);
        Shader.SetGlobalColor("_sunFogColor", sunFogColor * sunFogLight);
        Shader.SetGlobalColor("_HeightFogColor", heightFogColor);
        Shader.SetGlobalVector("_SunFogDir", _SunFogDir);
        RenderSettings.fogColor = gloabFogColor;
    }
}
