namespace CustomRenderFeatures
{
    using System;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEngine.Rendering;
    using UnityEngine.Rendering.Universal;


    [CreateAssetMenu(menuName = "Create/Renderering/Create RenderPassFeatureManager")]
    public class RendererFeaturesManager : ScriptableRendererFeature
    {
        [Serializable]
        public class SRenderPassFeatureManagerSettings : BaseSettings
        {
            public List<ScriptableRendererFeature> featureList = new List<ScriptableRendererFeature>();
        }

        public SRenderPassFeatureManagerSettings settings = new SRenderPassFeatureManagerSettings();

        public override void Create()
        {

        }

        // Here you can inject one or multiple render passes in the renderer.
        // This method is called when setting up the renderer once per-camera.
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {

            if (settings.isOn)
            {
                foreach (var item in settings.featureList)
                {
                    item.Create();
                    item.AddRenderPasses(renderer, ref renderingData);
                }
            }

        }
    }


}