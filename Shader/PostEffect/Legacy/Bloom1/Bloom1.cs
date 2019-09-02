using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom1 : MonoBehaviour
{
    public Shader shader;
    Material mat;

    [Range(1,10)]public int downSample = 2;
    [Range(0,1)]public float threshold = 0.5f;
    [Range(2,6)]public int iteraters;
    [Range(0,2)]public float blurIntensity;

    // Start is called before the first frame update
    void Start()
    {
        mat = new Material(shader);
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        var w = source.width / downSample;
        var h = source.height / downSample;
        // pass0
        mat.SetFloat("_Threshold",threshold);
        var buffer0 = RenderTexture.GetTemporary(w, h, 0);
        Graphics.Blit(source, buffer0, mat, 0);

        //pass1
        for (int i = 0; i < iteraters; i++)
        {
            var blurSize = 1 + blurIntensity * i;
            var buffer1 = RenderTexture.GetTemporary(w, h, 0);

            mat.SetFloat("_BlurSize", blurSize);
            Graphics.Blit(buffer0, buffer1, mat, 1);
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        }
        // pass2
        mat.SetTexture("_BloomTex",buffer0);
        Graphics.Blit(source, destination, mat, 2);
        RenderTexture.ReleaseTemporary(buffer0);
    }
}
