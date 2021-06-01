using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.Universal.Internal;

public class DRPPipelineVarables : ScriptableRendererFeature
{

    class CustomRenderPass : ScriptableRenderPass
    {
        public static int _LightColor0;
        public static int _WorldSpaceLightPos0;
        public static int _MainLightShadowmapTexture;
        public static int _ShadowBias;

        Matrix4x4[] m_MainLightShadowMatrices;
        public const int k_MaxCascades = 4;

        public CustomRenderPass()
        {
            _LightColor0 = Shader.PropertyToID("_LightColor0");
            _WorldSpaceLightPos0 = Shader.PropertyToID("_WorldSpaceLightPos0");
            _MainLightShadowmapTexture = Shader.PropertyToID("_MainLightShadowmapTexture");

            _ShadowBias = Shader.PropertyToID("unity_LightShadowBias");
        }

        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            SendLight(cmd, renderingData);
        }

        private void SendLight(CommandBuffer cmd, RenderingData renderingData)
        {
            var lightData = renderingData.lightData;
            if (lightData.mainLightIndex < 0)
                return;

            // light
            var vLight = lightData.visibleLights[lightData.mainLightIndex];
            cmd.SetGlobalVector(_WorldSpaceLightPos0, -vLight.localToWorldMatrix.GetColumn(2));
            cmd.SetGlobalColor(_LightColor0, vLight.finalColor);

            // shadow bias
            var shadowData = renderingData.shadowData;
            var shadowResolution = ShadowUtils.GetMaxTileResolutionInAtlas(shadowData.mainLightShadowmapWidth, shadowData.mainLightShadowmapHeight, shadowData.mainLightShadowCascadesCount);
            Matrix4x4 viewMat, projMat;
            ShadowSplitData shadowSplitData;
            renderingData.cullResults.ComputeDirectionalShadowMatricesAndCullingPrimitives(lightData.mainLightIndex, 0, shadowData.mainLightShadowCascadesCount, shadowData.mainLightShadowCascadesSplit, shadowResolution, vLight.light.shadowNearPlane, out viewMat, out projMat, out shadowSplitData);

            Vector4 shadowBias = ShadowUtils.GetShadowBias(ref vLight, lightData.mainLightIndex, ref renderingData.shadowData,projMat,shadowResolution);

            cmd.SetGlobalVector(_ShadowBias, shadowBias);
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }

    CustomRenderPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


