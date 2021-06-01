using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

#if UNITY_EDITOR
using UnityEditor;

[CustomEditor(typeof(CameraStackManager))]
public class CameraStackManagerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        var inst = target as CameraStackManager;
        base.OnInspectorGUI();

        GUILayout.BeginVertical("Box");
        if (GUILayout.Button("Sort"))
        {
            inst.SortCameras();
        }
        GUILayout.EndVertical();
    }
}
#endif

public class CameraStackManager : MonoBehaviour
{
    public Camera mainCamera;
    public Camera[] overlayCameras;

    public bool isAutoSort;

    // Start is called before the first frame update
    void Start()
    {
        if(isAutoSort)
            SortCameras();
    }

    public void SortCameras()
    {
        var mainData = mainCamera.GetComponent<UniversalAdditionalCameraData>();
        mainData.renderType = CameraRenderType.Base;
        mainData.cameraStack.Clear();

        foreach (var cam in overlayCameras)
        {
            var data = cam.GetComponent<UniversalAdditionalCameraData>();
            data.renderType = CameraRenderType.Overlay;
            
            
            mainData.cameraStack.Add(cam);
        }

    }
}
