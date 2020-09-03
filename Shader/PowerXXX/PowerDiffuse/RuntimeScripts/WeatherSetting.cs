using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class WeatherSetting : MonoBehaviour
{
    public bool plantsOn;
    public bool fogOn;
    public bool rainReflectionOn;
    public bool normalMapOn;
    public bool blinnOn;
    // Start is called before the first frame update
    void Start()
    {
        UpdateParams();
    }

    // Update is called once per frame
    void Update()
    {
#if UNITY_EDITOR
        UpdateParams();
#endif
    }

    public void UpdateParams()
    {
        Shader.SetGlobalInt("_PlantsOn", plantsOn ? 1 : 0);
        Shader.SetGlobalInt("_FogOn", fogOn ? 1 : 0);
        Shader.SetGlobalInt("_RainReflectionOn", rainReflectionOn ? 1 : 0);
        Shader.SetGlobalInt("_NormalMapOn", normalMapOn ? 1 : 0);
        Shader.SetGlobalInt("_BlinnOn", blinnOn ? 1 : 0);
    }

}
