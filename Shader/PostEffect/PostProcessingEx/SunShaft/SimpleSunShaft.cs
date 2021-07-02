using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;



[PostProcess(typeof(SimpleSunShaftRenderer),PostProcessEvent.AfterStack,"Custom/SimpleSunShaft")]
public class SimpleSunShaft : PostProcessEffectSettings
{
    [Range(0, 1)]
    public FloatParameter dentisy = new FloatParameter { value = 0.5f };

    [Range(0,1)]
    public FloatParameter decay = new FloatParameter { value = 0.5f };

    [Range(0,1)]
    public FloatParameter exposure = new FloatParameter { value = 0.5f };

    [Range(0,1)]
    public FloatParameter blend = new FloatParameter { value=0.5f};
    public Vector3Parameter lightSreenPos = new Vector3Parameter { value = new Vector3(0.5f, 0.5f, 1) };
}

public class SimpleSunShaftRenderer : PostProcessEffectRenderer<SimpleSunShaft>
{

    RenderTexture rt0,rt1;
    public override void Render(PostProcessRenderContext context)
    {
        var screenPos = settings.lightSreenPos.value;

        if (screenPos.x > 0 && screenPos.x < context.screenWidth && screenPos.y > 0 && screenPos.y < context.screenHeight)
        {
            CreateBuffers(context.screenWidth,context.screenHeight);
            
            var raySheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/SimpleSunShaftRay"));
            var blendSheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/SimpleSunShaftBlend"));

            //var screenPos = context.camera.WorldToScreenPoint(settings.lightTr.position);
            raySheet.properties.SetVector("_ScreenLightPos", new Vector4(settings.lightSreenPos.value.x / context.screenWidth, settings.lightSreenPos.value.y / context.screenHeight));
            raySheet.properties.SetFloat("_Dentisy", settings.dentisy);
            raySheet.properties.SetFloat("_Decay", settings.decay);
            raySheet.properties.SetFloat("_Exposure", settings.exposure);

            context.command.BlitFullscreenTriangle(context.source, rt0, raySheet, 0);
            context.command.BlitFullscreenTriangle(rt0, rt1, raySheet, 0);
            context.command.BlitFullscreenTriangle(rt1, rt0, raySheet, 0);
            context.command.BlitFullscreenTriangle(rt0, rt1, raySheet, 0);
            context.command.BlitFullscreenTriangle(rt1, rt0, raySheet, 0);

            blendSheet.properties.SetFloat("_Blend", settings.blend);
            blendSheet.properties.SetTexture("_RayTex", rt0);
            context.command.BlitFullscreenTriangle(context.source, context.destination, blendSheet, 0);
        }
        else
        {
            context.command.BlitFullscreenTriangle(context.source, context.destination);
        }
    }

    public override void Release()
    {
        if (rt0)
            RenderTexture.ReleaseTemporary(rt0);
        if (rt1)
            RenderTexture.ReleaseTemporary(rt1);
    }

    private void CreateBuffers(int w, int h)
    {
        if (!rt0)
            rt0 = RenderTexture.GetTemporary(w, h);
        if (!rt1)
            rt1 = RenderTexture.GetTemporary(w, h);
    }
}
