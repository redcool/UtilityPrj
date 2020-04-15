using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionVectorsCam : MonoBehaviour
{
    public Shader motionVectorShader;
    Material mat;
    // Start is called before the first frame update
    void Start()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.MotionVectors;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!mat)
        {
            mat = new Material(motionVectorShader);
        }

        Graphics.Blit(source, destination, mat);
    }
}
