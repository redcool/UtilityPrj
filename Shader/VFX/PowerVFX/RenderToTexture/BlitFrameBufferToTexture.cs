using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BlitFrameBufferToTexture : MonoBehaviour
{
    #if UNITY_2018_3_OR_NEWER
    [Header("Buffer Textures")]
    [SerializeField] RenderTexture colorRT;
    [SerializeField] RenderTexture depthRT;

    [Header("Camera events")]
    public CameraEvent blitColorEvent = CameraEvent.AfterForwardOpaque;
    public CameraEvent blitDepthEvent = CameraEvent.AfterForwardOpaque;

    [Header("Camera Settings")]
    [Tooltip("mobile need depth mode at least")]
    public DepthTextureMode camDepthTextureMode;

    Camera cam;
    CommandBuffer blitColor, blitDepth;

    public readonly int screenColorTextureId = Shader.PropertyToID("_ScreenColorTexture");
    public readonly int screenDepthTextureId = Shader.PropertyToID("_ScreenDepthTexture");
    // Start is called before the first frame update
    void Start()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = camDepthTextureMode;
        if(cam.depthTextureMode != DepthTextureMode.None)
        {
            return;
        }

        colorRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0);
        depthRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0);

        blitColor = new CommandBuffer { name = "blit color" };
        blitColor.Blit(BuiltinRenderTextureType.CurrentActive, colorRT);
        blitColor.SetGlobalTexture(screenColorTextureId,colorRT);
        cam.AddCommandBuffer(blitColorEvent, blitColor);

        blitDepth = new CommandBuffer { name = "blit depth" };
        blitDepth.Blit(BuiltinRenderTextureType.Depth, depthRT.colorBuffer);
        blitDepth.SetGlobalTexture(screenDepthTextureId,depthRT);
        cam.AddCommandBuffer(blitDepthEvent, blitDepth);
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
