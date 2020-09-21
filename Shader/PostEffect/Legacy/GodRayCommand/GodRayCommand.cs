using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[ExecuteAlways]
public class GodRayCommand : MonoBehaviour
{
    [Header("Basic")]
    public CameraEvent cameraEvent = CameraEvent.AfterForwardOpaque;
    //光源位置
    public Transform lightTransform;
    [Header("DownSample")]
    //Blur迭代次数
    [Range(1, 3)]
    public int blurIteration = 2;
    //降低分辨率倍率
    [Range(1, 5)]
    public int downSample = 2;

    Shader shader;
    [Header("Shader Params")]
    //高亮部分提取阈值
    public float intensityThreshold = 0.5f;
    //体积光颜色
    public Color lightColor = Color.white;
    //光强度
    [Range(0.0f, 30.0f)]
    public float lightFactor = 0.5f;
    //径向模糊uv采样偏移值
    [Range(0.0f, 10.0f)]
    public float samplerScale = 1;

    //产生体积光的范围
    [Range(0.0f, 10f)]
    public float lightRadius = 2.0f;
    //提取高亮结果Pow倍率，适当降低颜色过亮的情况
    [Range(1.0f, 10f)]
    public float lightPowFactor = 3.0f;

    private Camera cam = null;
    
    CommandBuffer godRayBuffer;

    Material mat;
    Material CurrentMaterial
    {
        get
        {
            if (!mat)
            {
                shader = Shader.Find("Hidden/PostEffects/GodRay");
                mat = new Material(shader);
                mat.hideFlags = HideFlags.HideAndDontSave;
            }
            return mat;
        }
    }

    void Start()
    {
        cam = GetComponent<Camera>();
        godRayBuffer = new CommandBuffer();
        godRayBuffer.name = "GodRay Buffer";

        //1 copy screen
        var copyScreenId = Shader.PropertyToID("_CopyScreenTex");
        godRayBuffer.GetTemporaryRT(copyScreenId, -1, -1, 0, FilterMode.Bilinear);
        godRayBuffer.Blit(BuiltinRenderTextureType.CurrentActive, copyScreenId);
        //2 blit copy screen to temp1
        int rtWidth = Screen.width >> downSample;
        int rtHeight = Screen.height >> downSample;
        int temp1 = Shader.PropertyToID("_DownSampleTex1");
        godRayBuffer.GetTemporaryRT(temp1, rtWidth, rtHeight, 0, FilterMode.Bilinear);
        godRayBuffer.Blit(copyScreenId, temp1, CurrentMaterial, 0);


        //3 get blur,temp1 <--> temp2
        var temp2 = Shader.PropertyToID("_DownSampeleTex2");
        godRayBuffer.GetTemporaryRT(temp2, rtWidth, rtHeight, 0, FilterMode.Bilinear);

        var sampleOffset = samplerScale / Screen.width;
        for (int i = 0; i < blurIteration; i++)
        {
            var offset = sampleOffset * (i * 2 + 1);
            godRayBuffer.SetGlobalVector("_offsets", new Vector4(offset, offset, 0, 0));
            godRayBuffer.Blit(temp1, temp2, CurrentMaterial, 1);

            offset = sampleOffset * (i * 2 + 2);
            godRayBuffer.SetGlobalVector("_offsets",new Vector4(offset,offset,0,0));
            godRayBuffer.Blit(temp2,temp1,CurrentMaterial,1);
        }
        godRayBuffer.ReleaseTemporaryRT(temp2);

        //godRayBuffer.SetGlobalColor("");
        godRayBuffer.SetGlobalTexture("_BlurTex", temp1);
        //godRayBuffer.Blit(temp1, BuiltinRenderTextureType.CameraTarget);

        //4 compose
        godRayBuffer.Blit(copyScreenId, BuiltinRenderTextureType.CameraTarget, CurrentMaterial, 2);

        cam.AddCommandBuffer(cameraEvent, godRayBuffer);
    }
    void OnDestroy()
    {
        if (cam && godRayBuffer != null)
            cam.RemoveCommandBuffer(cameraEvent, godRayBuffer);
    }
    private void OnPreRender()
    {
        Vector3 viewPortLightPos = lightTransform == null ? new Vector3(.5f, .5f, 0) : cam.WorldToViewportPoint(lightTransform.position);
        
        CurrentMaterial.SetFloat("_IntensityThreshold", intensityThreshold);
        CurrentMaterial.SetVector("_ViewPortLightPos", new Vector4(viewPortLightPos.x, viewPortLightPos.y, viewPortLightPos.z, 0));
        CurrentMaterial.SetFloat("_LightRadius", lightRadius);
        CurrentMaterial.SetFloat("_PowFactor", lightPowFactor);
        CurrentMaterial.SetColor("_LightColor", lightColor);
        CurrentMaterial.SetFloat("_LightFactor", lightFactor);
    }

    private void OnGUI()
    {
        Vector3 viewPortLightPos = lightTransform == null ? new Vector3(.5f, .5f, 0) : cam.WorldToViewportPoint(lightTransform.position);
        GUILayout.Box(viewPortLightPos.ToString());
    }

}
