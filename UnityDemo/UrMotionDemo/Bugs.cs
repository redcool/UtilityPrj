using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UrMotion;
using Random = UnityEngine.Random;

public class Bugs : MonoBehaviour
{
    public float delayTime = 1;

    [Header("移动")]
    public Vector2 basePos = new Vector2(5,0);
    public Vector2 range = new Vector2(1,1);

    public float moveScale = 0.1f;
    public float ratio = 0.2f, bounce = 0.1f;
    [Header("随机")]
    public Vector2 perlinSpeed = new Vector2(1f,2f);
    public float perlinScale = 1f;

    [Header("旋转")]
    public float rotateRatio = 1;

    [Header("飞走")]
    Vector2 basePosOffset;
    public float maxFlybackSpeed = 10f;

    [Header("屏幕缩放")]
    public float screenScale = 1;

    Vector2 dir;
    Camera mainCam;
    // Start is called before the first frame update
    void Start()
    {
        mainCam = Camera.main;
        var g = gameObject;

        StartCoroutine(WaitForRun(g));
    }

    bool IsHitBug()
    {
        var ray = mainCam.ScreenPointToRay(Input.mousePosition);
        var hits = new RaycastHit2D[1];

        var count = Physics2D.RaycastNonAlloc(ray.origin, ray.direction, hits);
        if (count == 0)
            return false;

        foreach (var item in hits)
        {
            if (item.collider.GetComponent<Bugs>())
                return true;
        }
        return false;
    }

    IEnumerator WaitForRun(GameObject g)
    {
        Func<Vector2> scaleByY = () => {
            if (!mainCam || Mathf.Approximately(screenScale,0))
                return Vector2.one;

            var viewPos = mainCam.WorldToViewportPoint(transform.position);
            var rate = (1 - viewPos.y)*screenScale;
            return new Vector2(rate, rate);
        };


        for (; ; )
        {
            var p = new Vector2(Random.Range(-range.x, range.x), Random.Range(-range.y, range.y));
            p += basePosOffset + basePos;

            var vel = default(IEnumerator<Vector2>);
            var m = g.MotionP();
            m.AimSpringAt(p, ratio, bounce).Amplify(moveScale).Capture(out vel);
            m.Perlin(perlinSpeed).Amplify(vel.Magnitude().Amplify(perlinScale));

            var r = g.MotionR();
            r.AimRatioAt(vel.ToAngle().Offset(-90f), rotateRatio);

            var s = g.MotionS();
            s.AimSpringAt(scaleByY, 0.1F, 0.2F);

            yield return new WaitForSeconds(delayTime);
        }
    }

    // Update is called once per frame
    void Update()
    {
        UpdateFlyoff();
    }

    void UpdateFlyoff()
    {
        if (IsButtonDown())
        {
            if (IsHitBug())
            {
                basePosOffset = Random.onUnitSphere * 50;
            }
            return;
        }

        basePosOffset = Vector2.MoveTowards(basePosOffset, Vector2.zero, maxFlybackSpeed * Time.deltaTime);
    }

    private bool IsButtonDown()
    {
        return Input.GetMouseButton(0);
    }

    
}
