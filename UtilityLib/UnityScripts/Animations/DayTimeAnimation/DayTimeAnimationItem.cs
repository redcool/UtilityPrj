using System;
using UnityEngine;
/// <summary>
/// 24h动画播放控制项
/// </summary>
public class DayTimeAnimationItem :MonoBehaviour
{
    Animation anim;

    private void Awake()
    {
        anim = GetComponent<Animation>();
        if (anim)
        {
            anim.playAutomatically = false;
            anim.Stop();

            if (!anim.clip)
                UseFirstClip();
        }

        enabled = anim && anim.clip;
    }

    private void UseFirstClip()
    {
        foreach (AnimationState state in anim)
        {
            if (!state.clip)
                continue;

            anim.clip = state.clip;
            break;
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