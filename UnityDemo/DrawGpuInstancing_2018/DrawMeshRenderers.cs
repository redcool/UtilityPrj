using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class DrawMeshGroupInfo
{
    public Mesh mesh;
    public Material mat;

    /// <summary>
    /// 要绘制的物体,untiy限制最多1023,这里用list来分组.
    /// </summary>
    public List<List<Matrix4x4>> transformsGroup = new List<List<Matrix4x4>>();
    public List<List<Vector4>> lightmapSTsGroup = new List<List<Vector4>>();
    public List<MaterialPropertyBlock> blockList = new List<MaterialPropertyBlock>();

    public int lightmapId;

    int groupId = 0;
    public void AddRender(Matrix4x4 transform,Vector4 lightmapST)
    {
        // new group
        if(transformsGroup.Count <= groupId)
        {
            transformsGroup.Add(new List<Matrix4x4>());
            lightmapSTsGroup.Add(new List<Vector4>());
            blockList.Add(new MaterialPropertyBlock());
        }
        // get current group
        var transforms = transformsGroup[groupId];
        var lightmapSTs = lightmapSTsGroup[groupId];

        transforms.Add(transform);
        lightmapSTs.Add(lightmapST);

        // check need increment groupId.
        if(transforms.Count >= 1023)
        {
            groupId++;
        }
    }
}
/// <summary>
/// 调用Graphics.DrawMeshInstanced来绘制物体.
/// 
/// 解决2018之前,gpu instancing对光照图的处理未实现.
/// 2018后,烘焙后的物体,可以正常进行gpu instancing.
/// 
/// group:[
///     mesh:[
///         transformsGroup:[
///             transforms:[]
///         ]
///     ]
/// ]
/// 
/// </summary>
public class DrawMeshRenderers : MonoBehaviour
{
    public Texture2D[] lightmaps;

    Dictionary<Mesh, DrawMeshGroupInfo> dict = new Dictionary<Mesh, DrawMeshGroupInfo>();
    List<DrawMeshGroupInfo> groupList = new List<DrawMeshGroupInfo>();

    // Use this for initialization
    void Start()
    {
        var renders = GetComponentsInChildren<MeshRenderer>();

        AddToGroup(renders);

        groupList.AddRange(dict.Values);

        SetupGroupLightmapInfo();
    }

    private void SetupGroupLightmapInfo()
    {
        foreach (var groupInfo in groupList)
        {
            for (int i = 0; i < groupInfo.lightmapSTsGroup.Count; i++)
            {
                var block = groupInfo.blockList[i];
                var lightmapSTs = groupInfo.lightmapSTsGroup[i];

                block.SetTexture("unity_Lightmap", lightmaps[groupInfo.lightmapId]);
                block.SetVectorArray("_LightmapST", lightmapSTs.ToArray());
            }
        }
    }

    private void AddToGroup(MeshRenderer[] renders)
    {
        for (int i = 0; i < renders.Length; i++)
        {
            var r = renders[i];
            r.gameObject.SetActive(false);

            var info = GetDrawInfoFromDict(r);
            info.lightmapId = r.lightmapIndex;
            info.AddRender(r.transform.localToWorldMatrix, r.lightmapScaleOffset);
        }
    }

    DrawMeshGroupInfo GetDrawInfoFromDict(MeshRenderer r)
    {
        DrawMeshGroupInfo info;
        var filter = r.GetComponent<MeshFilter>();
        if (!dict.TryGetValue(filter.sharedMesh, out info))
        {
            info = new DrawMeshGroupInfo();
            info.mesh = filter.sharedMesh;
            info.mat = r.sharedMaterial;
            info.mat.EnableKeyword("LIGHTMAP_ON");

            dict.Add(filter.sharedMesh, info);
        }
        return info;
    }

    // Update is called once per frame
    void Update()
    {
        DrawGroup();
    }

    private void DrawGroup()
    {
        foreach (var group in groupList)
        {
            for (int i = 0; i < group.transformsGroup.Count; i++)
            {
                var transforms = group.transformsGroup[i];
                var block = group.blockList[i];
                Graphics.DrawMeshInstanced(group.mesh, 0, group.mat, transforms, block);
            }
        }
    }
}
