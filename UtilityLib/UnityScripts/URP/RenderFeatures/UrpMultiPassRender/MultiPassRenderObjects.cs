using System.Collections.Generic;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine.Scripting.APIUpdating;
using UnityEngine.Experimental.Rendering.Universal;
using FilterSettings = UnityEngine.Experimental.Rendering.Universal.RenderObjects.FilterSettings;
using CustomCameraSettings = UnityEngine.Experimental.Rendering.Universal.RenderObjects.CustomCameraSettings;

namespace UnityEngine.Experimental.Rendering.Universal
{


    public class MultiPassRenderObjects : ScriptableRendererFeature
    {
        [System.Serializable]
        public class Settings
        {
            public string passTag = "MultiPassRenderObjects";
            public RenderPassEvent Event = RenderPassEvent.AfterRenderingSkybox;

            public FilterSettings filterSettings = new FilterSettings();

            public Material overrideMaterial = null;
            //public int overrideMaterialPassIndex = 0;

            public bool overrideDepthState = false;
            public CompareFunction depthCompareFunction = CompareFunction.LessEqual;
            public bool enableWrite = true;

            public StencilStateData stencilSettings = new StencilStateData();

            public CustomCameraSettings cameraSettings = new CustomCameraSettings();
        }

        public Settings settings = new Settings();

        MultPassRenderObjectsPass renderObjectsPass;

        public override void Create()
        {
            FilterSettings filter = settings.filterSettings;

            // Render Objects pass doesn't support events before rendering prepasses.
            // The camera is not setup before this point and all rendering is monoscopic.
            // Events before BeforeRenderingPrepasses should be used for input texture passes (shadow map, LUT, etc) that doesn't depend on the camera.
            // These events are filtering in the UI, but we still should prevent users from changing it from code or
            // by changing the serialized data.
            if (settings.Event < RenderPassEvent.BeforeRenderingPrepasses)
                settings.Event = RenderPassEvent.BeforeRenderingPrepasses;

            renderObjectsPass = new MultPassRenderObjectsPass(settings.passTag, settings.Event, filter.PassNames,
                filter.RenderQueueType, filter.LayerMask, settings.cameraSettings);

            renderObjectsPass.overrideMaterial = settings.overrideMaterial;
            //renderObjectsPass.overrideMaterialPassIndex = settings.overrideMaterialPassIndex;
            

            if (settings.overrideDepthState)
                renderObjectsPass.SetDetphState(settings.enableWrite, settings.depthCompareFunction);

            if (settings.stencilSettings.overrideStencilState)
                renderObjectsPass.SetStencilState(settings.stencilSettings.stencilReference,
                    settings.stencilSettings.stencilCompareFunction, settings.stencilSettings.passOperation,
                    settings.stencilSettings.failOperation, settings.stencilSettings.zFailOperation);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(renderObjectsPass);
        }
    }
}

