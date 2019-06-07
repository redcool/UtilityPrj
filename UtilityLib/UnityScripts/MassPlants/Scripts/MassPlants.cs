using UnityEngine;
using System.Collections;
using System;
using Random = UnityEngine.Random;

[Serializable]
public class PlantProfile
{
    public Mesh mesh;
    public int instanceCount = 100000;

    public bool needUpdate=true;

    public Material[] materials;
    public ComputeBuffer[] positionBuffers;

    uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
    public ComputeBuffer[] argsBuffers;

    public Bounds bounds;
    public Vector2 sizeRange = new Vector2(0.5f, 1);

    Vector4[] positions;
    int subMeshCountNeedDraw;
    void Init()
    {
        positions = new Vector4[instanceCount];
        for (int i = 0; i < instanceCount; i++)
        {
            positions[i] = new Vector4(
                Random.Range(bounds.min.x, bounds.max.x),
                Random.Range(bounds.min.y, bounds.max.y),
                Random.Range(bounds.min.z, bounds.max.z),
                Random.Range(sizeRange.x, sizeRange.y)
                );
        }

        subMeshCountNeedDraw = Mathf.Min(mesh.subMeshCount, materials.Length);

        positionBuffers = new ComputeBuffer[subMeshCountNeedDraw];
        argsBuffers = new ComputeBuffer[subMeshCountNeedDraw];

    }
    public void Update()
    {
        Clear();
        Init();

        for (int i = 0; i < subMeshCountNeedDraw; i++)
        {
            UpdatePositionBuffer(i);
            UpdateArgsBuffer(i);
        }
    }
    public void Clear()
    {
        positions = null;
        for (int i = 0; i < subMeshCountNeedDraw; i++)
        {
            positionBuffers[i].Release();
            argsBuffers[i].Release();
        }
    }

    public void UpdatePositionBuffer(int i)
    {
        if (positionBuffers[i] != null)
            positionBuffers[i].Release();

        positionBuffers[i] = new ComputeBuffer(instanceCount, 16);
        positionBuffers[i].SetData(positions);
        materials[i].SetBuffer("positionBuffer", positionBuffers[i]);
    }

    public void UpdateArgsBuffer(int i)
    {
        if (argsBuffers[i] == null)
            argsBuffers[i] = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);

        if (mesh)
        {
            args[0] = mesh.GetIndexCount(i);
            args[1] = (uint)instanceCount;
            args[2] = mesh.GetIndexStart(i);
            args[3] = mesh.GetBaseVertex(i);
        }
        argsBuffers[i].SetData(args);
    }

    public void Draw()
    {
        for (int i = 0; i < subMeshCountNeedDraw; i++)
        {
            Graphics.DrawMeshInstancedIndirect(
                mesh,
                i,
                materials[i],
                bounds,
                argsBuffers[i]
                );
        }

    }
}

public class MassPlants : MonoBehaviour
{
    public PlantProfile[] profiles;

    public Vector3 radius = new Vector3(50,0,50);

    private void Start()
    {
    }

    void Update()
    {

        foreach (var p in profiles)
        {
            if (p.needUpdate)
            {
                p.needUpdate = false;

                p.bounds = new Bounds(transform.position, radius);
                p.Update();
            }

            p.Draw();
        }

    }

    void OnDisable()
    {
        foreach (var p in profiles)
        {
            p.Clear();
        }
    }
}