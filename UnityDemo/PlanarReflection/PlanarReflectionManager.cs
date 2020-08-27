using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanarReflectionManager : MonoBehaviour
{
    public Transform reflectionPlane;
    public string reflectionTexture = "_ReflectionTex";
    Camera reflectionCam;
    Camera mainCam;

    RenderTexture reflectionRT;

    // Start is called before the first frame update
    void Start()
    {
        reflectionCam = CreateCamera("Reflection Camera");
        mainCam = Camera.main;
        reflectionRT = new RenderTexture(Screen.width, Screen.height, 24);

        if (!reflectionPlane)
            enabled = false;
    }

    private void Update()
    {
        RenderReflection();
        SendToShader();
    }

    private void OnDestroy()
    {
        Destroy(reflectionRT);
    }

    private void SendToShader()
    {
        Shader.SetGlobalTexture(reflectionTexture, reflectionRT);
    }

    private void RenderReflection()
    {
        reflectionCam.CopyFrom(mainCam);
        reflectionCam.targetTexture = reflectionRT;

        var camForward = mainCam.transform.forward;
        var camUp = mainCam.transform.up;
        var camPos = mainCam.transform.position;

        var camForwardPlaneSpace = reflectionPlane.InverseTransformDirection(camForward);
        var camUpPlaneSpace = reflectionPlane.InverseTransformDirection(camUp);
        var camPosPlaneSpace = reflectionPlane.InverseTransformPoint(camPos);

        camForwardPlaneSpace.y *= -1;
        camUpPlaneSpace.y *= -1;
        camPosPlaneSpace.y *= -1;

        camForward = reflectionPlane.TransformDirection(camForwardPlaneSpace);
        camUp = reflectionPlane.TransformDirection(camUpPlaneSpace);
        camPos = reflectionPlane.TransformPoint(camPosPlaneSpace);


        //reflectionCam.transform.up = camUp;
        reflectionCam.transform.position = camPos;
        //reflectionCam.transform.forward = camForward;
        reflectionCam.transform.LookAt(camPos + camForward, camUp);

        reflectionCam.Render();

    }

    Camera CreateCamera(string cameraName)
    {
        var camGo = new GameObject(cameraName);
        var cam = camGo.AddComponent<Camera>();
        cam.enabled = false;
        return cam;
    }
}
