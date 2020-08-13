using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways]
public class LightingProcess : MonoBehaviour
{
    public Light lightComp;
    public bool revertLightDir = true;
    [Header("Main Light Params")]
    [SerializeField] Vector4 lightDir;
    [SerializeField] Vector4 lightColor;

    [Header("Other Params")]
    [SerializeField][Range(0.01f,1)]float shadowIntensityInLightmap;
    [SerializeField] Color ambientColor = new Color(.2f, .2f, .2f);
    [SerializeField] [Range(0, 1)] float shadowStrength = 1;
    [SerializeField] [Range(0, 1)] float shadowEdge = 1;
    [SerializeField] [Range(0, 1)] float lightingType = 0.5f;
    // Start is called before the first frame update
    void Awake()
    {
        lightComp = GetComponent<Light>();
    }

#if UNITY_EDITOR
    private void Update()
    {
        OnEnable();
    }
#endif
    // Update is called once per frame
    void OnEnable()
    {
        lightDir = transform.forward;
        if (revertLightDir)
        {
            lightDir *= -1;
        }
        lightColor = lightComp.color * lightComp.intensity;
        //lightShadowIntensity = lightComp.shadowStrength;

        SendToShader();
    }

    void SendToShader()
    {
        Shader.SetGlobalVector("_MainLightDir", lightDir);
        Shader.SetGlobalColor("_MainLightColor", lightColor);
        Shader.SetGlobalFloat("_MainLightShadowIntensity", shadowIntensityInLightmap);
        Shader.SetGlobalColor("_AmbientColor", ambientColor);
        Shader.SetGlobalFloat("_ShadowStrength", shadowStrength);
        Shader.SetGlobalFloat("_ShadowEdge", shadowEdge);
        Shader.SetGlobalFloat("_LightingType", lightingType);
    }

    void OnDisable()
    {
        lightDir = default(Vector4);
        lightColor = default(Color);
        SendToShader();
    }
}
