using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/// <summary>
/// 控制动画按时间(24h)进行播放
/// </summary>
public class DayTimeAnimationDriver : MonoBehaviour
{
    [Header("(游戏)一天是(现实中)多少秒?")]
    [Min(1)]
    public float secondsADay = 30;

    float elapsedSecs;
    [Header("Debug Info")]
    [SerializeField]private float timeRate;
    [SerializeField]float hour;

    static List<DayTimeAnimationItem> animList = new List<DayTimeAnimationItem>();
    public static void Add(DayTimeAnimationItem item) {
        if (!animList.Contains(item))
        {
            animList.Add(item);
        }
    }
    public static void Remove(DayTimeAnimationItem item)
    {
        if (animList.Contains(item))
        {
            animList.Remove(item);
        }
    }


    // Update is called once per frame
    void Update()
    {
        UpdateTimeRate();
        hour = timeRate * 24;

        UpdateAnimations();
    }

    private void UpdateAnimations()
    {
        foreach (var item in animList)
        {
            if(item.isActiveAndEnabled)
                item.UpdateAnimation(timeRate);
        }
    }

    void UpdateTimeRate()
    {
        elapsedSecs += Time.deltaTime;
        elapsedSecs %= secondsADay;

        timeRate = elapsedSecs / secondsADay;
    }
}
