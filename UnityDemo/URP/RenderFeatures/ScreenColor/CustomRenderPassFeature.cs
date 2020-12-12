using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomRenderPassFeature : ScriptableRendererFeature
{
    [Serializable]public class Settings
    {
        public Material blitMat;
        public RenderPassEvent @event;
    }
    class CustomRenderPass : ScriptableRenderPass
    {
        public Settings settings;
        private int customCameraTextureId = Shader.PropertyToID("_CustomScreenTexture");

        RenderTargetIdentifier sourceId;
        public void Init(RenderTargetIdentifier sourceId)
        {
            this.sourceId = sourceId;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            cmd.GetTemporaryRT(customCameraTextureId, Screen.width, Screen.height,0);
        }


        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get();
            Blit(cmd, sourceId, customCameraTextureId,settings.blitMat);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            if (customCameraTextureId != -1)
                cmd.ReleaseTemporaryRT(customCameraTextureId);

        }
    }

    CustomRenderPass m_ScriptablePass;

    public Settings settings;

    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();
        m_ScriptablePass.settings = settings;

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = settings.@event;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (!settings.blitMat)
            return;

        m_ScriptablePass.Init(renderer.cameraColorTarget);
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


