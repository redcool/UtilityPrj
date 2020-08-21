using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Mathematics;

[ExecuteAlways]
public class RenderShadowRGBA : MonoBehaviour
{
    Camera cam;
    public RenderTexture shadowRT;
    public Shader shadowShader;
    [Range(0,1)]public float shadowIntensity=0.5f;

    // Start is called before the first frame update
    void Start()
    {
        cam = GetComponent<Camera>();
        cam.enabled = false;
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = Color.white;
    }


    void CreateShadowRT()
    {
        var needCreate = (!shadowRT);
        if (needCreate)
        {
            shadowRT = new RenderTexture(1024, 1024, 24,RenderTextureFormat.Default);
        }
    }

    private void Update()
    {
        CreateShadowRT();
        cam.targetTexture = shadowRT;
       
        cam.RenderWithShader(shadowShader, "RenderType");

        Shader.SetGlobalTexture("_GlobalShadowMap", shadowRT);

        var p = GL.GetGPUProjectionMatrix(cam.projectionMatrix,false);
        var v = cam.worldToCameraMatrix;
        var t = cam.transform.worldToLocalMatrix;
        var camTransform = p * v ;
        Shader.SetGlobalMatrix("_CamTransform", camTransform);

        Shader.SetGlobalFloat("_GlobalShadowIntensity",1-shadowIntensity);
    }
}
