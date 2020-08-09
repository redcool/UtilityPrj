using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class Light : MonoBehaviour
{
    public float cookieSize=5;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        var m = transform.worldToLocalMatrix;
        m[3, 3] = cookieSize;
        //Shader.SetGlobalMatrix("_WorldToLight", m);
        Shader.SetGlobalMatrix("unity_WorldToLight", m);
    }
}
