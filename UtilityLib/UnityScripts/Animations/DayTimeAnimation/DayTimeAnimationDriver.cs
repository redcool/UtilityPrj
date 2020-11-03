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

    public bool autoDaytime;

    [Header("昼夜时间比例(0:夜,1:昼)")]
    [Range(0,1)]public float timeRate;

    float elapsedSecs;
    [Header("Debug Info")]
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
        if(autoDaytime)
            UpdateTimeRate();
        
        timeRate -= Mathf.Floor(timeRate);

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
