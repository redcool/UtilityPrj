using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Mathematics;

public class LocalToWorldTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log(transform.localToWorldMatrix);

        var m = CalcLocalToWorldMatrix();
        Debug.Log((Matrix4x4)m);
    }


    float3 CalcLocalToWorldPos(Transform tr)
    {
        var p = Vector3.zero;

        while (tr)
        {
            p += tr.localPosition;
            tr = tr.parent;
            if (!tr)
                break;

            p = Vector3.Scale(tr.localRotation * p, tr.localScale);
        }
        return p;
    }

    float4x4 CalcLocalToWorldMatrix()
    {
        var tr = transform;
        var p = Vector3.zero;
        var s = new float3(1);
        var r = Quaternion.identity;

        while (tr)
        {
            s *= (float3)tr.localScale; //add scale
            r *= tr.localRotation; // add rotation
            p += tr.localPosition;// translate local

            tr = tr.parent;
            if (!tr)
                break;

            p = Vector3.Scale(tr.localRotation * p, tr.localScale); //rotate local first,then scale
        }

        return float4x4.TRS(p, r, s);
    }
}
