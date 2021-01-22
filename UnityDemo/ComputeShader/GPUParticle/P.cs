using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Unity.Collections;
using UnityEngine;

public class P : MonoBehaviour
{
    public struct Particle
    {
        public Vector2 pos;
        public Vector2 velocity;
    }

    public ComputeShader computeShader;
    public int count = 10000000;
    public float radius = 100;
    int warpSize;

    public Material mat;

    ComputeBuffer particleBuffer;
    int kernelId;
    Particle[] particles;
    // Start is called before the first frame update
    void Start()
    {
        warpSize = Mathf.CeilToInt((float)count / 1024);

        particles = new Particle[count];
        for (int i = 0; i < count; i++)
        {
            particles[i] = new Particle
            {
                pos = Random.insideUnitCircle * radius,
                velocity = Vector2.zero
            };
        }

        var stride = Marshal.SizeOf(typeof(Particle));
        particleBuffer = new ComputeBuffer(count, stride);
        particleBuffer.SetData(particles);

        kernelId = computeShader.FindKernel("CalcParticles");
        computeShader.SetBuffer(kernelId, "particles", particleBuffer);
        mat.SetBuffer("particles", particleBuffer);
    }

    // Update is called once per frame
    void Update()
    {
        computeShader.SetFloats("mousePos", GetMousePos());
        computeShader.SetFloat("deltaTime", Time.deltaTime);
        computeShader.Dispatch(kernelId, warpSize, 1, 1);

        if (Input.GetKeyDown(KeyCode.R))
        {
            particleBuffer.SetData(particles);
        }
    }

    //private void OnDrawGizmos()
    //{
    //    Gizmos.DrawWireSphere(Vector3.zero, radius);
    //    if (particleBuffer == null)
    //        return;

    //    var p = new Particle[count]; 
    //    particleBuffer.GetData(p);
    //    for (int i = 0; i < count; i++)
    //    {
    //        Gizmos.DrawCube(p[i].pos,Vector3.one*0.1f);
    //    }
    //}

    private float[] GetMousePos()
    {
        var p = Camera.main.ScreenToWorldPoint(Input.mousePosition);
        return new[] { p.x, p.y };
    }

    private void OnRenderObject()
    {
        mat.SetPass(0);
        Graphics.DrawProceduralNow(MeshTopology.Points, 1, count);
    }

    private void OnDestroy()
    {
        if (particleBuffer != null)
            particleBuffer.Dispose();

    }
}
