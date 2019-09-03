using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur1 : MonoBehaviour
{
    public Shader shader;
    public float blur;
    Material mat;
    RenderTexture rt;
    // Start is called before the first frame update
    void Start()
    {
        mat = new Material(shader);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(!rt || rt.width != source.width || rt.height != source.height)
        {
            rt = new RenderTexture(source.width, source.height, 0);
            //Graphics.Blit(source, rt);
        }

        mat.SetFloat("_Blur",blur);
        Graphics.Blit(source, rt, mat);
        Graphics.Blit(rt, destination);
    }
}
