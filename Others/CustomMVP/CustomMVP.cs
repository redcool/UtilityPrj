using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

[ExecuteAlways]
public class CustomeMVP : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        var cam = Camera.main;
        cam.ResetWorldToCameraMatrix();
        cam.ResetProjectionMatrix();

        float4x4 view = float4x4.LookAt(cam.transform.position, cam.transform.position + Vector3.forward, cam.transform.up);
        float4x4 projection = float4x4.PerspectiveFov(math.radians(cam.fieldOfView), (float)Screen.width / Screen.height, cam.nearClipPlane, cam.farClipPlane);

        Shader.SetGlobalMatrix("_ViewMatrix", view);
        Shader.SetGlobalMatrix("_ProjectionMatrix",projection);
        Shader.SetGlobalMatrix("_WorldMatrix",transform.localToWorldMatrix);
    }
}
