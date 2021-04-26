using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PowerURPLitFeatures : ScriptableRendererFeature
{

    [Serializable]
    public struct Settings
    {
        [Header("Main Light Shadow")]
        [NonSerialized]public bool _MainLightShadowCascadeOn;

        public bool _LightmapOn;

        public bool _Shadows_ShadowMaskOn;
    }


    class PowerURPLitUpdateParamsPass : ScriptableRenderPass
    {
        public Settings settings;
        public void UpdateParams(CommandBuffer cmd)
        {
            var asset = UniversalRenderPipeline.asset;

            cmd.SetGlobalInt(nameof(settings._MainLightShadowCascadeOn), asset.shadowCascadeCount>1 ? 1 : 0);
            cmd.SetGlobalInt(nameof(settings._LightmapOn),settings._LightmapOn ? 1 : 0);
            cmd.SetGlobalInt(nameof(settings._Shadows_ShadowMaskOn),settings._Shadows_ShadowMaskOn ? 1 : 0);

        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            base.Configure(cmd, cameraTextureDescriptor);
            UpdateParams(cmd);
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            
        }
    }
    public Settings settings = new Settings();
    PowerURPLitUpdateParamsPass pass;


    /// <inheritdoc/>
    public override void Create()
    {
        pass = new PowerURPLitUpdateParamsPass();
        pass.settings = settings;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(pass);
    }
}


