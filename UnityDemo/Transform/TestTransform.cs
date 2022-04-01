using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Unity.Mathematics;
using System.Text;

#if UNITY_EDITOR

[CustomEditor(typeof(TestTransform))]
public class TestTransformE : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        var inst = target as TestTransform;

        if (GUILayout.Button("Show"))
            inst.Start();

        if (GUILayout.Button("Clean"))
            inst.Clean();
    }
}
#endif

public class TestTransform : MonoBehaviour
{
    public Camera cam;
    public List<GameObject> coordObjs = new List<GameObject>();
    // Start is called before the first frame update
    void ShowCoords()
    {
        var pos = cam.transform.position;

        var aspect = cam.aspect;
        var n = cam.nearClipPlane;
        var f = cam.farClipPlane;
        var fovYHalf = Mathf.Deg2Rad * cam.fieldOfView/2f;

        var nh = Mathf.Tan(fovYHalf) * n;
        var nw = nh * aspect;

        var n0 = new Vector3(-nw,-nh,n);
        var n1 = new Vector3(-nw,nh,n);
        var n2 = new Vector3(nw, nh, n);
        var n3 = new Vector3(nw, -nh, n);

        var fn = f / n;
        var f0 = n0 * fn;
        var f1 = n1 * fn;
        var f2 = n2 * fn;
        var f3 = n3 * fn;

        //var fh = Mathf.Tan(fovYHalf) * f;
        //var fw = fh * aspect;
        //f0 = new Vector3(-fw,-fh,f);
        //f1 = new Vector3(-fw,fh,f);
        //f2 = new Vector3(fw,fh,f);
        //f3 = new Vector3(fw,-fh,f);

        var coords = new[] { 
            n0,n1,n2,n3,f0,f1,f2,f3
        };

        var projMat = float4x4.PerspectiveOffCenter(-nw, nw, -nh, nh, n, f);
        var viewMat = float4x4.LookAt(Vector3.zero, Vector3.forward, Vector3.up);
        
        var camViewMat = cam.worldToCameraMatrix;

        var sb = new StringBuilder();
        for (int i = 0; i < coords.Length; i++)
        {
            var worldPos = pos + coords[i];
            coordObjs[i].transform.position = worldPos;

            var viewPos = worldPos;
            //viewPos = camViewMat.MultiplyPoint(worldPos);
            viewPos.z *= -1;

            float4 vertex = new float4(viewPos, 1);
            //var projPos1 = cam.projectionMatrix.MultiplyPoint(p);
            var projPos = math.mul(projMat, vertex);

            sb.AppendLine(worldPos +" -> "+vertex +" -> "+projPos+" -> "+ (projPos/projPos.w));
        }
        Debug.Log(sb.ToString());
    }

    public void Start()
    {
        cam = Camera.main;
        TryInit();
        ShowCoords();
    }

    private void TryInit()
    {
        if (coordObjs.Count == 0)
        {
            for (int i = 0; i < 8; i++)
            {
                var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                go.transform.localScale = Vector3.one * (i<4?0.2f:1f);
                go.name = "c " + i;
                coordObjs.Add(go);
            }
        }
    }

    public void Clean()
    {
        for (int i = 0; i < coordObjs.Count; i++)
        {
            DestroyImmediate(coordObjs[i]);
        }
        coordObjs.Clear();
    }

    private void OnDrawGizmos1()
    {
        for (int i = 0; i < coordObjs.Count; i++)
        {
            Gizmos.DrawSphere(coordObjs[i].transform.position, 0.2f);
        }
    }


}
