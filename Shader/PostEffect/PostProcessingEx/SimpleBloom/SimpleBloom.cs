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
        [Range(0,10)]
        public FloatParameter intensity = new FloatParameter { value = 1 };

        [Range(1, 7)]
        public IntParameter iterators = new IntParameter { value = 4 };

        [Range(0, 10)]
        public FloatParameter threshold = new FloatParameter { value = 0.5f };

        [Range(0, 1)]
        public FloatParameter softThreshold = new FloatParameter { value = 0.5f };

        [Range(0.5f,2)]
        public FloatParameter smoothBorder = new FloatParameter { value = 1 };

        public ColorParameter bloomColor = new ColorParameter { value = Color.white };

        

        //public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        //{
        //    return enabled.value;
        //}
    }

    public sealed class SimpleBloomRenderer : PostProcessEffectRenderer<SimpleBloom>
    {
        const int GRAB_ILLUM_PASS = 0;
        const int BOX_DOWN = 1;
        const int BOX_UP = 2;
        const int COMBINE_PASS = 3;

        RenderTexture[] textures = new RenderTexture[16];
        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/SimpleBloom"));

            var knee = settings.threshold * settings.softThreshold;
            Vector4 filter;
            filter.x = settings.threshold;
            filter.y = filter.x - knee;
            filter.z = 2 * knee;
            filter.w = 0.25f / (knee + 0.0001f);

            sheet.properties.SetVector("_Filter", filter);

            var w = context.width / 2;
            var h = context.height / 2;
            var format = context.sourceFormat;

            // pass 0
            var buffer0 = textures[0] = RenderTexture.GetTemporary(w, h, 0, format);
            context.command.BlitFullscreenTriangle(context.source, buffer0, sheet, GRAB_ILLUM_PASS);

            //pass 1,downsample
            int i = 1;
            for (i = 1; i < settings.iterators; i++)
            {
                w /= 2;
                h /= 2;
                if (h < 2)
                    break;

                //blur1
                var buffer1 = textures[i] = RenderTexture.GetTemporary(w, h, 0, format);
                context.command.BlitFullscreenTriangle(buffer0, buffer1, sheet, BOX_DOWN);

                buffer0 = buffer1;
            }
            
            // upsample
            var lastId = i-1;
            for (i -= 2;  i>= 0; i--)
            {
                var buffer1 = textures[i];
                if (lastId < textures.Length)
                {
                    sheet.properties.SetTexture("_BloomTex", textures[lastId]);
                    lastId--;
                }
                context.command.BlitFullscreenTriangle(buffer0, buffer1, sheet, BOX_UP);
                //textures[i] = null;
                //RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            for (i = 0; i < settings.iterators; i++)
            {
                RenderTexture.ReleaseTemporary(textures[i]);
            }

            //context.command.Blit(buffer0, context.destination);
            //RenderTexture.ReleaseTemporary(buffer0);
            //return;

            //pass 2
            sheet.properties.SetFloat("_Intensity",Mathf.GammaToLinearSpace(settings.intensity));
            sheet.properties.SetFloat("_SmoothBorder", Mathf.GammaToLinearSpace(settings.smoothBorder));
            sheet.properties.SetTexture("_BloomTex", buffer0);
            sheet.properties.SetColor("_BloomColor", settings.bloomColor);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, COMBINE_PASS);
            RenderTexture.ReleaseTemporary(buffer0);
        }
    }

}