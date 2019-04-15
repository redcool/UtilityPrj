using MyTools;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(LightProbeGroup))]
public class ProbeSettings : MonoBehaviour {
#if UNITY_EDITOR
    public Vector3 size = new Vector3(10,10,10);
    public Vector3Int counts = new Vector3Int(2,2,2);
    public Color borderColor = Color.white;

    List<Vector3> GetPoints(Vector3 size,Vector3Int counts)
    {
        var extends = size / 2;
        var min = transform.position - extends;
        var max = transform.position + extends;
        var boxSize = max - min;
        var gaps = new Vector3(size.x / counts.x, size.y / counts.y, size.z / counts.z);

        var pointList = new List<Vector3>();

        for (int x = 0; x <= counts.x; x++)
        {
            for (int y = 0; y <= counts.y; y++)
            {
                for (int z = 0; z <= counts.z; z++)
                {
                    pointList.Add(Vector3.Scale(new Vector3(x, y, z), gaps) - extends);
                }
            }
        }
        return pointList;
    }

    public void ReplaceProbes()
    {
        var g = gameObject.GetOrAddComponent<LightProbeGroup>();
        g.probePositions = GetPoints(size, counts).ToArray();
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = borderColor;
        Gizmos.DrawWireCube(transform.position, size);
    }

#endif
}
