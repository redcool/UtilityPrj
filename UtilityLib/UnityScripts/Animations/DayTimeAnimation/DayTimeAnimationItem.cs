using System;
using UnityEngine;
/// <summary>
/// 24h动画播放控制项
/// </summary>
public class DayTimeAnimationItem :MonoBehaviour
{
    [SerializeField]Animation anim;

    private void Awake()
    {
        anim = GetComponent<Animation>();
        enabled = anim && anim.clip;
        if (anim)
        {
            anim.playAutomatically = false;
            anim.Stop();
        }
    }

    private void OnEnable()
    {
        DayTimeAnimationDriver.Add(this);
    }

    private void OnDisable()
    {
        DayTimeAnimationDriver.Remove(this);
    }

    public void UpdateAnimation(float timeRate)
    {
        if (!anim || !anim.clip)
            return;

        anim.clip.SampleAnimation(gameObject,timeRate * anim.clip.length);
    }
}