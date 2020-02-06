using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

[ExecuteAlways]
public class CustomRenderer : MonoBehaviour
{
    public Mesh mesh;
    public Material material;

    void OnEnable()
    {
        CustomCamera.AddRenderer(this);
    }

    void OnDisable()
    {
        CustomCamera.RemoveRenderer(this);
    }
}
