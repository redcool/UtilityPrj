using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class BezierCurve
{
    public static Vector3 Linear(Vector3 p0,Vector3 p1,float t)
    {
        return (1 - t) * p0 + t * p1;
    }

    public static Vector3 Square(Vector3 p0, Vector3 p1, Vector3 p2, float t)
    {
        float it = 1 - t;
        float it2 = it * it;
        float t2 = t * t;
        return it2 * p0 + 2 * t * it * p1 + t2 * p2;
    }
    public static Vector3 Cubic(Vector3 p0,Vector3 p1,Vector3 p2,Vector3 p3,float t)
    {
        float it = 1 - t;
        float it2 = it * it;
        float it3 = it * it * it;
        float t2 = t * t;
        float t3 = t * t * t;

        return it3 * p0 + 3 * t * it2 * p1 + 3 * t2 * it * p2 + t3 * p3;
    }
}

public class BezierTest : MonoBehaviour
{
    public Transform tr0, tr1, tr2;
    [Range(0,1)]public float t;
    public Transform target;

    [Header("Auto")]
    public bool isAutoMove;
    public float speed = 4;
    public bool isRevertMove;

    [Header("Debug")]
    public int splineSegCount = 100;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (!tr0 || !tr1 || !tr2 || !target)
            return;

        if (isAutoMove)
        {
            var moveSpeed = speed * Time.deltaTime;
            var endT = isRevertMove ? 0 : 1;
            t = Mathf.MoveTowards(t, endT, moveSpeed);

            if(t == endT)
            {
                Debug.Log("finish");
            }
        }

        var p0 = tr0.position;
        var p1 = tr1.position;
        var p2 = tr2.position;

        var p = BezierCurve.Square(p0, p1, p2, t);
        target.position = p;
    }

    private void OnDrawGizmos()
    {
        if (!tr0 || !tr1 || !tr2)
            return;

        var p0 = tr0.position;
        var p1 = tr1.position;
        var p2 = tr2.position;

        var step = 1f / splineSegCount;
        for (int i = 0; i < splineSegCount; i++)
        {
            var start = BezierCurve.Square(p0, p1, p2, step * i);
            var end = BezierCurve.Square(p0, p1, p2, step * (i + 1));
            Gizmos.DrawLine(start, end);
        }
    }
}
