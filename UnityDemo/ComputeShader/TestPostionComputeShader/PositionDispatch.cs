using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PositionDispatch : MonoBehaviour
{
    public int resolution = 10;

    public ComputeBuffer positionBuffer;
    public ComputeShader computeShader;

    public Material mat;
    public Mesh mesh;
    // Start is called before the first frame update
    void Start()
    {
        positionBuffer = new ComputeBuffer(resolution * resolution, 3 * 4);

    }

    // Update is called once per frame
    void Update()
    {
        var step = 2f / resolution;
        computeShader.SetFloat("_Step", step);
        computeShader.SetFloat("_Time",Time.time);
        computeShader.SetInt("_Resolution", resolution);

        var kernelId = computeShader.FindKernel("TestPosition");

        computeShader.SetBuffer(kernelId, "_Positions", positionBuffer);
        var groups = Mathf.CeilToInt(resolution / 8f);
        computeShader.Dispatch(kernelId, groups, groups, 1);

        var data = new Vector3[positionBuffer.count];
        positionBuffer.GetData(data);

        mat.SetBuffer("_Positions", positionBuffer);
        mat.SetFloat("_Scale",step);

        var bounds = new Bounds(Vector3.zero,Vector3.one * 5);
        Graphics.DrawMeshInstancedProcedural(mesh, 0, mat, bounds, resolution * resolution);
    }
}
