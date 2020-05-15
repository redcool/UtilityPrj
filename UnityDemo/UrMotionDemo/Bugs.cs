using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UrMotion;
using Random = UnityEngine.Random;

public class Bugs : MonoBehaviour
{
    [Header("移动")]
    public float delayTime = 1;
    public Vector2 basePos = new Vector2(5,0);
    public Vector2 range = new Vector2(1,1);

    public float moveScale = 0.1f;
    public float moveRatio = 0.2f, moveBounce = 0.1f;
    [Header("随机")]
    public Vector2 perlinSpeed = new Vector2(1f,2f);
    public float perlinScale = 1f;

    [Header("旋转")]
    public float rotateRatio = 1;

    [Header("飞走")]
    public float flyOffRatio = 0.1f;
    public float maxFlybackSpeed = 10f;
    Vector2 basePosOffset;

    [Header("屏幕缩放")]
    public float screenScale = 1;

    Vector2 dir;
    Camera mainCam;
    Collider2D collider2D;
    GameObject g;

    // Start is called before the first frame update
    void Start()
    {
        mainCam = Camera.main;
        g = gameObject;

        StartCoroutine(WaitForRun());

        collider2D = GetComponent<Collider2D>();
    }

    bool IsHitBug2D()
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

    bool IsHitBug()
    {
        var ray = mainCam.ScreenPointToRay(Input.mousePosition);
        var hits = new RaycastHit[2];
        var count = Physics.RaycastNonAlloc(ray, hits);
        if (count == 0)
            return false;

        foreach (var item in hits)
        {
            if (item.collider.GetComponent<Bugs>())
                return true;
        }
        return false;
    }

    Vector2 ScaleByScreenY()
    {
        if (!mainCam || Mathf.Approximately(screenScale, 0))
            return Vector2.one;

        var viewPos = mainCam.WorldToViewportPoint(transform.position);
        var rate = Mathf.Max(0.1f, 1 - viewPos.y) * screenScale;
        return new Vector2(rate, rate);
    }

    void MoveToTarget(float ratio)
    {
        Func<Vector2> scaleByScreenY = () => ScaleByScreenY();

        var p = new Vector2(Random.Range(-range.x, range.x), Random.Range(-range.y, range.y));
        p += basePosOffset + basePos;

        var vel = default(IEnumerator<Vector2>);
        var m = g.MotionP();
        m.AimSpringAt(p, ratio, moveBounce).Amplify(moveScale).Capture(out vel);
        m.Perlin(perlinSpeed).Amplify(vel.Magnitude().Amplify(perlinScale));

        var r = g.MotionR();
        r.AimRatioAt(vel.ToAngle().Offset(-90f), rotateRatio);

        var s = g.MotionS();
        s.AimSpringAt(scaleByScreenY, 0.1F, 0.2F);
    }

    IEnumerator WaitForRun()
    {
        for (; ; )
        {
            MoveToTarget(moveRatio);
            yield return new WaitForSeconds(delayTime);
            Debug.Log("run");
        }
    }

    IEnumerator WaitForFlyoff()
    {
        MoveToTarget(flyOffRatio);
        yield return new WaitForSeconds(5);
        Debug.Log("flyoff");
        StartCoroutine(WaitForRun());
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
            var isHit = collider2D ? IsHitBug2D() : IsHitBug();
            if (isHit)
            {
                basePosOffset = Random.insideUnitCircle.normalized * 50;

                StopAllCoroutines();
                StartCoroutine(WaitForFlyoff());
            }
            return;
        }
        //fly back
        basePosOffset = Vector2.MoveTowards(basePosOffset, Vector2.zero, maxFlybackSpeed * Time.deltaTime);
    }

    private bool IsButtonDown()
    {
        return Input.GetMouseButton(0);
    }

    
}
