using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class RenderToTexture : MonoBehaviour
{
    #if UNITY_2018_3_OR_NEWER
    public RenderTexture colorRT;
    public RenderTexture depthRT;
    public RenderTexture screenRT;

    Camera cam;
    CommandBuffer blitColor, blitDepth, blitFrame;

    int screenColorTextureId = Shader.PropertyToID("_ScreenColorTexture");
    int screenDepthTextureId = Shader.PropertyToID("_ScreenDepthTexture");
    // Start is called before the first frame update
    void Start()
    {
        cam = GetComponent<Camera>();

        colorRT = new RenderTexture(cam.pixelWidth,cam.pixelHeight,0,RenderTextureFormat.RGB111110Float);
        depthRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 24, RenderTextureFormat.Depth);
        screenRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 24, RenderTextureFormat.RGB111110Float);

        blitColor = new CommandBuffer();
        blitColor.name = "blit color";
        blitColor.Blit(screenRT, colorRT);
        cam.AddCommandBuffer(CameraEvent.AfterSkybox, blitColor);

        blitDepth = new CommandBuffer();
        blitDepth.name = "blit depth";
        blitDepth.Blit(screenRT.depth, depthRT.colorBuffer);
        cam.AddCommandBuffer(CameraEvent.AfterForwardOpaque, blitDepth);

        blitFrame = new CommandBuffer();
        blitFrame.name = "blit frame";
        blitFrame.Blit(screenRT, (RenderTexture)null);
        cam.AddCommandBuffer(CameraEvent.AfterEverything, blitFrame);

    }
    private void OnPreRender()
    {
        Shader.SetGlobalTexture(screenColorTextureId, colorRT);
        Shader.SetGlobalTexture(screenDepthTextureId, depthRT);
        cam.SetTargetBuffers(screenRT.colorBuffer, screenRT.depthBuffer);
    }

    private void OnDestroy()
    {
        cam.RemoveCommandBuffer(CameraEvent.AfterSkybox, blitColor);
        cam.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, blitDepth);
        cam.RemoveCommandBuffer(CameraEvent.AfterEverything, blitFrame);

        blitColor.Dispose();
        blitDepth.Dispose();
        blitFrame.Dispose();
    }
#endif
}
