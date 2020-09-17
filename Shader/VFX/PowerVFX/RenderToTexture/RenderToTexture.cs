using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class RenderToTexture : MonoBehaviour
{
    #if UNITY_2018_3_OR_NEWER
    public RenderTexture colorRT;
    public RenderTexture depthRT;
    public bool enableDepthTextureMode;

    Camera cam;
    CommandBuffer blitColor, blitDepth;

    int screenColorTextureId = Shader.PropertyToID("_ScreenColorTexture");
    int screenDepthTextureId = Shader.PropertyToID("_ScreenDepthTexture");
    // Start is called before the first frame update
    void Start()
    {
        cam = GetComponent<Camera>();
        if (!cam)
            return;

        if (enableDepthTextureMode)
            cam.depthTextureMode = DepthTextureMode.Depth;

        if (!colorRT)
            colorRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0, RenderTextureFormat.RGB111110Float);
        if (!depthRT)
            depthRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 24, RenderTextureFormat.Depth);

        blitColor = new CommandBuffer();
        blitColor.name = "blit color";
        blitColor.Blit(BuiltinRenderTextureType.CurrentActive, colorRT);
        blitColor.SetGlobalTexture(screenColorTextureId, colorRT);
        cam.AddCommandBuffer(CameraEvent.AfterSkybox, blitColor);

        blitDepth = new CommandBuffer();
        blitDepth.name = "blit depth";
        blitDepth.Blit(BuiltinRenderTextureType.Depth, depthRT.colorBuffer);
        blitDepth.SetGlobalTexture(screenDepthTextureId, depthRT);
        cam.AddCommandBuffer(CameraEvent.AfterForwardOpaque, blitDepth);

    }


    private void OnDestroy()
    {
        cam.RemoveCommandBuffer(CameraEvent.AfterSkybox, blitColor);
        cam.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, blitDepth);

        blitColor.Dispose();
        blitDepth.Dispose();

    }
#endif
}
