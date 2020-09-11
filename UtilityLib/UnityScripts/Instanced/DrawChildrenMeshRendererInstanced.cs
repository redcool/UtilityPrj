#define ZHU_XIAN
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

/// <summary>
/// 对instancing的物体,按2013个进行分组.
/// groupId是originalTransformsGroup的索引,同时表示绘制中的相同的批次
/// </summary>
public class DrawMeshInstancedGroupInfo
{
    public Mesh mesh;
    public Material mat;

    /// <summary>
    /// 要绘制的物体,untiy限制最多1023,这里用list来分组.
    /// 存放所有的 变换信息
    /// </summary>
    public List<List<Matrix4x4>> originalTransformsGroup = new List<List<Matrix4x4>>();
    /// <summary>
    /// 用于绘制的列表
    /// 对originalTransformList进行洗牌,按概率过滤一部分
    /// </summary>
    public List<List<Matrix4x4>> displayTransformsGroup = new List<List<Matrix4x4>>();

    public List<List<Vector4>> lightmapCoordsList = new List<List<Vector4>>();

    /// <summary>
    /// 每组(1023个)会分配一个 block
    /// </summary>
    public List<MaterialPropertyBlock> blockList = new List<MaterialPropertyBlock>();

    public int lightmapId;

    int groupId = 0;
    public void AddRender(Matrix4x4 transform,Vector4 lightmapST)
    {
        // new group
        if(originalTransformsGroup.Count <= groupId)
        {
            originalTransformsGroup.Add(new List<Matrix4x4>());
            displayTransformsGroup.Add(new List<Matrix4x4>());
            lightmapCoordsList.Add(new List<Vector4>());
            blockList.Add(new MaterialPropertyBlock());
        }
        // get current group
        var transforms = originalTransformsGroup[groupId];
        transforms.Add(transform);

        var lightmapSTs = lightmapCoordsList[groupId];
        lightmapSTs.Add(lightmapST);

        var transformsCulled = displayTransformsGroup[groupId];
        transformsCulled.Add(transform);

        // check need increment groupId.
        if (transforms.Count >= 1023)
        {
            groupId++;
        }
    }
}
/// <summary>
/// 解决,gpu instancing对光照图的处理
/// 
/// 调用Graphics.DrawMeshInstanced来绘制物体.
/// 烘焙+gpu instancing,使用此代码来绘制.
/// 
/// groups:[
///     mesh:[
///         transformsGroup:[
///             transforms:[]
///         ]
///     ]
/// ]
/// 
/// </summary>
public class DrawChildrenMeshRendererInstanced : MonoBehaviour
{
    public Texture2D[] lightmaps;
    public bool enableLightmap = true;
    public bool destroyGameObjectWhenCannotUse = true;
    public bool culledUnderLevel2= true;

    [Header("销毁概率")]
    [Range(0,1)]public float culledRatio = 0.5f;
    public bool forceRefresh;

    Dictionary<Mesh, DrawMeshInstancedGroupInfo> dict = new Dictionary<Mesh, DrawMeshInstancedGroupInfo>();
    List<DrawMeshInstancedGroupInfo> groupList = new List<DrawMeshInstancedGroupInfo>();

    Renderer[] renders;

    public static List<DrawChildrenMeshRendererInstanced> InstanceList { private set; get; }
    private void Awake()
    {
        if (!InstanceList.Contains(this))
            InstanceList.Add(this);
    }

    // Use this for initialization
    void Start()
    {
        renders = GetComponentsInChildren<MeshRenderer>();

        if (!CheckDeviceSupport()) //设备不支持instance 或者 等级为 0
        {
            enabled = false;
            return;
        }

        AddToGroup(renders);
        groupList.AddRange(dict.Values);

        // lightmaps handle
        if (lightmaps.Length > 0)
        {
            SetupGroupLightmapInfo();
        }

        //culled by device level
        if (culledUnderLevel2)
        {
            var levelId = GetLevelId();
            if (levelId <= 2)
                CullInstances(culledRatio);
        }

        //destroy 
        DestroyGameObjects();
    }

    private void DestroyGameObjects()
    {
        foreach (var item in renders)
        {
            // destroy items;
            if (destroyGameObjectWhenCannotUse)
            {
                Destroy(item.gameObject);
            }
            else
                item.gameObject.SetActive(false);
        }

    }
    /// <summary>
    /// low => high = [0,1,2,3] 
    /// </summary>
    /// <returns></returns>
    int GetLevelId()
    {
        var levelId = 2;
#if ZHU_XIAN
        levelId = (int)Display.DeviceClassify;
#endif
        return levelId;
    }
    
    bool CheckDeviceSupport()
    {
        return SystemInfo.supportsInstancing;
    }

    private void SetupGroupLightmapInfo()
    {
        foreach (var groupInfo in groupList)
        {
            for (int i = 0; i < groupInfo.lightmapCoordsList.Count; i++)
            {
                var block = groupInfo.blockList[i];
                var lightmapSTs = groupInfo.lightmapCoordsList[i];

                block.SetTexture("unity_Lightmap", lightmaps[groupInfo.lightmapId]);
                block.SetVectorArray("_LightmapST", lightmapSTs.ToArray());
                block.SetInt("_DrawInstanced", 1);
            }
        }
    }

    private void AddToGroup(Renderer[] renders)
    {
        for (int i = 0; i < renders.Length; i++)
        {
            var r = renders[i];
            r.gameObject.SetActive(false);

            var info = GetInfoFromDict(r);
            info.lightmapId = r.lightmapIndex;
            info.AddRender(r.transform.localToWorldMatrix, r.lightmapScaleOffset);
        }
    }

    DrawMeshInstancedGroupInfo GetInfoFromDict(Renderer r)
    {
        DrawMeshInstancedGroupInfo info;
        var filter = r.GetComponent<MeshFilter>();
        if (!dict.TryGetValue(filter.sharedMesh, out info))
        {
            info = new DrawMeshInstancedGroupInfo();
            info.mesh = filter.sharedMesh;
            info.mat = r.sharedMaterial;
            info.mat.enableInstancing = true;

            if (enableLightmap)
                info.mat.EnableKeyword("LIGHTMAP_ON");
            else
                info.mat.DisableKeyword("LIGHTMAP_ON");

            dict.Add(filter.sharedMesh, info);
        }
        return info;
    }

    // Update is called once per frame
    void Update()
    {
        if (forceRefresh)
        {
            forceRefresh = false;

            CullInstances(culledRatio);
        }
        DrawGroupList();
    }

    /// <summary>
    /// shuffle originalList,keep maxCount
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="originalList"></param>
    /// <param name="maxCount"></param>
    /// <returns></returns>
    public static List<T> Shuffle<T>(List<T> originalList, int maxCount)
    {
        //shuffle
        var set = new HashSet<int>();
        while (set.Count < maxCount)
        {
            var id = Random.Range(0, originalList.Count);
            if (set.Contains(id))
                continue;

            set.Add(id);
        }
        // copy into list
        var arr = set.ToArray();
        var list = new List<T>();
        for (int i = 0; i < arr.Length; i++)
        {
            list.Add(originalList[i]);
        }
        return list;
    }

    void CullInstances(float culledRatio)
    {
        foreach (var group in groupList)
        {
            for (int i = 0; i < group.originalTransformsGroup.Count; i++)
            {
                var transforms = group.originalTransformsGroup[i];
                group.displayTransformsGroup[i] = Shuffle(transforms, (int)(transforms.Count * Mathf.Clamp01(culledRatio)));
            }
        }
    }

    private void DrawGroupList()
    {
        foreach (var group in groupList)
        {
            for (int i = 0; i < group.displayTransformsGroup.Count; i++)
            {
                var transforms = group.displayTransformsGroup[i];
                var block = group.blockList[i];

                Graphics.DrawMeshInstanced(group.mesh, 0, group.mat, transforms, block);
            }
        }
    }
}
