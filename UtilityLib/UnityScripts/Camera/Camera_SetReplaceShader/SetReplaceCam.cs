using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class SetReplaceCam : MonoBehaviour
{
    public Shader replaceShader;

    Camera cam;

    private void OnValidate()
    {
    }

    private void OnEnable()
    {
        cam = GetComponent<Camera>();
        if(cam)
            cam.SetReplacementShader(replaceShader, "");
    }

    private void OnDisable()
    {
        if(cam)
            cam.ResetReplacementShader();
    }
}
