using UnityEngine;
using System;

#if UNITY_EDITOR
using UnityEditor;
[CustomEditor(typeof(HeightFogSetting))]
public class HeightFogSettingEditor : Editor
{
    const string helpStr = "Waring : 禁用此组件,关闭高度雾与雾.";
    public override void OnInspectorGUI()
    {
        EditorGUILayout.HelpBox(helpStr, MessageType.Warning);
        base.OnInspectorGUI();
    }
}
#endif
/// <summary>
/// HeightFogSetting
/// 可以有多个实例,需要通过enable来开关.
/// </summary>
[ExecuteInEditMode]
public class HeightFogSetting : MonoBehaviour
{
    public enum FogMode
    {
        UnityFog,SphereFog
    }
    public static HeightFogSetting Instance { private set; get; }

    /// <summary>
    /// 检测 fog是否开启
    /// </summary>
    public static event Func<bool> OnCheckFogOn;

    [Header("Fog Mode")]
    public FogMode fogMode;
    FogMode lastFogMode = (FogMode)(-1);

    [Header("Height Fog")]
    public bool isHeightFogOn = true;
    public float min = 0;
    public float max = 100;

    public Color heightFogMinColor = new Color(0, 0, 0.2f);
    public Color heightFogColor = new Color(0,0,0.2f);

    [Header("Fog")]
    public float near = 25;
    public float far = 100;
    public Color gloabFogColor = new Color(0,0,0.3f);
    public Color fogNearColor = Color.gray;
    public bool isPixelFog = true;

    [Header("Fast SSS")]
    [HideInInspector] public Color sunFogColor = new Color(0.2f, 0.5f, 0.3f);
    [HideInInspector]  [Range(1, 10)] public float sunFogLight = 1;
    [HideInInspector]  public Vector3 sunFogDir = new Vector3(0, 0.5f, 0);

    public readonly int
        heightFogMinColorId = Shader.PropertyToID("_HeightFogMinColor"),
        fogNearColorId = Shader.PropertyToID("_FogNearColor"),
        heightFogMinId = Shader.PropertyToID("_HeightFogMin"),
        heightFogMaxId = Shader.PropertyToID("_HeightFogMax"),
        heightFogNearId = Shader.PropertyToID("_HeightFogNear"),
        heightFogFarId = Shader.PropertyToID("_HeightFogFar"),
        sunFogColorId = Shader.PropertyToID("_sunFogColor"),
        sunFogDirId = Shader.PropertyToID("_SunFogDir"),
        heightFogColorId = Shader.PropertyToID("_HeightFogColor"),
        fogModeId = Shader.PropertyToID("_FogMode")
        ;

    public const string
        IS_FOG_ON = "_FogOn",
        IS_HEIGHT_FOG_ON = "_HeightFogOn",
        IS_PIXEL_FOG_ON = "_PixelFogOn";
    private void OnEnable()
    {
        Instance = this;
        if (OnCheckFogOn != null && !OnCheckFogOn())
        {
            enabled = false;
            return;
        }
        Shader.EnableKeyword("FOG_ON");
        Shader.SetGlobalInt(IS_FOG_ON, 1);
        Shader.SetGlobalInt(IS_HEIGHT_FOG_ON, 1);
        RenderSettings.fog = true;

        ApplyHeightFogSet();
    }

    private void OnDisable()
    {
        Shader.DisableKeyword("FOG_ON");
        Shader.SetGlobalInt(IS_FOG_ON, 0);
        Shader.SetGlobalInt(IS_HEIGHT_FOG_ON, 0);
        RenderSettings.fog = false;
    }
    private void OnDestroy()
    {
        Instance = null;
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

        Shader.SetGlobalInt(IS_HEIGHT_FOG_ON, isHeightFogOn ? 1 : 0);
        Shader.SetGlobalInt(IS_FOG_ON, enabled ? 1 : 0);
        Shader.SetGlobalInt(IS_PIXEL_FOG_ON, isPixelFog ? 1 : 0);

        Shader.SetGlobalFloat(heightFogMinId, min);
        Shader.SetGlobalFloat(heightFogMaxId, max);

        Shader.SetGlobalFloat(heightFogNearId, RenderSettings.fogStartDistance);
        Shader.SetGlobalFloat(heightFogFarId, RenderSettings.fogEndDistance);
        Shader.SetGlobalColor(heightFogColorId, heightFogColor);
        Shader.SetGlobalColor(heightFogMinColorId, heightFogMinColor);
        Shader.SetGlobalColor(fogNearColorId, fogNearColor);

        //Shader.SetGlobalColor(sunFogColorId, sunFogColor * sunFogLight);
        //Shader.SetGlobalVector(sunFogDirId, sunFogDir);

        RenderSettings.fogColor = gloabFogColor;
        RenderSettings.fogStartDistance = near;
        RenderSettings.fogEndDistance = far;

        UpdateFogMode();
    }

    private void UpdateFogMode()
    {
        if (lastFogMode != fogMode)
        {
            Debug.Log(lastFogMode);
            lastFogMode = fogMode;
            Shader.SetGlobalInt(fogModeId, (int)fogMode);
        }
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
