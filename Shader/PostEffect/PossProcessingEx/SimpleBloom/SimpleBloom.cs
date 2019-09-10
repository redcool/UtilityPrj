namespace PostProcessiong
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEngine.Rendering;
    using UnityEngine.Rendering.PostProcessing;

    [Serializable]
    [PostProcess(typeof(SimpleBloomRenderer), PostProcessEvent.AfterStack, "Custom/SimpleBloom")]
    public sealed class SimpleBloom : PostProcessEffectSettings
    {
        [Range(0.5f,2)]
        public FloatParameter intensity = new FloatParameter { value = 1 };
        [Range(0.5f,2)]
        public FloatParameter power = new FloatParameter { value = 1 };

        [Range(1, 10)]
        public IntParameter downSample = new IntParameter { value = 2 };

        [Range(0, 1), Tooltip("Threshold")]
        public FloatParameter threshold = new FloatParameter { value = 0.5f };

        [Range(0, 1)]
        public FloatParameter blurIntensity = new FloatParameter { value = 0.5f };

        [Range(1, 7)]
        public IntParameter iterators = new IntParameter { value = 2 };

        public ColorParameter bloomColor = new ColorParameter { value = Color.white };

        //public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        //{
        //    return enabled.value;
        //}
    }

    public sealed class SimpleBloomRenderer : PostProcessEffectRenderer<SimpleBloom>
    {
        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/SimpleBloom"));

            var w = context.width / settings.downSample;
            var h = context.height / settings.downSample;
            

            // pass 0
            sheet.properties.SetFloat("_Threshold", settings.threshold);
            var buffer0 = RenderTexture.GetTemporary(w, h, 0);
            context.command.BlitFullscreenTriangle(context.source, buffer0, sheet, 0);

            // bloom1 buffer
            var mainBloomBuffer = RenderTexture.GetTemporary(w, h, 0);
            context.command.BlitFullscreenTriangle(buffer0, mainBloomBuffer, sheet, 1);


            //pass 1
            for (int i = 0; i < settings.iterators-1; i++)
            {
                var blurSize = 1 + i * settings.blurIntensity;
                sheet.properties.SetFloat("_BlurSize", blurSize);

                var buffer1 = RenderTexture.GetTemporary(w, h, 0);
                context.command.BlitFullscreenTriangle(buffer0, buffer1, sheet, 1);
                RenderTexture.ReleaseTemporary(buffer0);

                buffer0 = buffer1;
            }
            //pass 2
            sheet.properties.SetFloat("_Intensity",Mathf.GammaToLinearSpace(settings.intensity));
            sheet.properties.SetFloat("_Power", Mathf.GammaToLinearSpace(settings.power));
            sheet.properties.SetTexture("_BloomTex", buffer0);
            sheet.properties.SetColor("_BloomColor", settings.bloomColor);
            sheet.properties.SetTexture("_MainBloomTex",mainBloomBuffer);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 2);
            RenderTexture.ReleaseTemporary(buffer0);
            RenderTexture.ReleaseTemporary(mainBloomBuffer);
        }
    }

}