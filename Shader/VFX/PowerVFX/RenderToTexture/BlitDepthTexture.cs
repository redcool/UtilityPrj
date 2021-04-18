using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class BlitDepthTexture : MonoBehaviour
{
    public RenderTexture depthRT;
    public RenderTexture colorRT;
    public RenderTexture screenDepthTex;

    private CommandBuffer blitDepthBuf = null;

    private Camera cam = null;

    private void Awake()
    {
        cam = Camera.main;

        SetupBuffers();

    }

    void SetupBlitDepth()
    {
        DisposeBlitBuffer();

        screenDepthTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.RHalf);
        screenDepthTex.name = "ScreenDepth Texture";

        blitDepthBuf = new CommandBuffer();
        blitDepthBuf.name = "CommandBuffer_DepthBuffer";
        blitDepthBuf.Blit(depthRT.depthBuffer, screenDepthTex.colorBuffer);
        blitDepthBuf.SetGlobalTexture("_CameraDepthTexture", screenDepthTex);
        blitDepthBuf.SetGlobalTexture("_CameraColorTexture",colorRT);

        cam.AddCommandBuffer(CameraEvent.AfterForwardOpaque, blitDepthBuf);
    }

    private void DisposeBlitBuffer()
    {
        if (blitDepthBuf != null)
        {
            cam.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, blitDepthBuf);
            blitDepthBuf.Dispose();
        }
    }

    void SetupBuffers()
    {
        if (!colorRT || Screen.width != colorRT.width)
        {
            colorRT = new RenderTexture(Screen.width,Screen.height, 0, RenderTextureFormat.RGB111110Float);
            colorRT.name = "MainColorBuffer";

            depthRT = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Depth);
            depthRT.name = "Main Depth Buffer";


            cam.SetTargetBuffers(colorRT.colorBuffer, depthRT.depthBuffer);

            SetupBlitDepth();
        }
    }

    private void Update()
    {
        SetupBuffers();
    }

    private void OnDestroy()
    {
        DisposeBlitBuffer();
    }


    private void OnPostRender()
    {
        //目前的机制不需要这次拷贝
        Graphics.Blit(colorRT, (RenderTexture)null);
    }
}