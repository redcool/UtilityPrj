using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// DaytimeAnimation 间接控制的unity属性
/// 比如 RenderSettings的属性
/// </summary>
[ExecuteInEditMode]
public class DaytimeForwardParams : MonoBehaviour
{
    public Color ambientColor = Color.gray;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        RenderSettings.ambientSkyColor = ambientColor;
        
    }
}
