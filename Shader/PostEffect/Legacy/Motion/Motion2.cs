using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Motion2 : MonoBehaviour
{
    public Shader shader;
    Material mat;
    public float blur;

    Matrix4x4 lastVP;
    // Start is called before the first frame update
    void Start()
    {
        mat = new Material(shader);

        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        var vp = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
        var vpInverse = vp.inverse;

        mat.SetFloat("_Blur",blur);
        mat.SetMatrix("_VPInvert", vpInverse);
        mat.SetMatrix("_LastVP", lastVP);

        Graphics.Blit(source, destination, mat, 0);

        lastVP = vp;
    }
}
