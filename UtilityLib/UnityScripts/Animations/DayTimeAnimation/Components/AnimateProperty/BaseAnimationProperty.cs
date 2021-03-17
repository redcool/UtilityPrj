//#define DAYTIMEk_ANIMATION
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 动画记录材质属性
/// </summary>
[ExecuteAlways]
public class BaseAnimationProperty : MonoBehaviour
{
    public Material mat;

    [Header("材质属性")]
    public string propName;

    void Awake()
    {
        if (mat)
        {
#if DAYTIME_ANIMATION
            DayTimeAnimationDriver.OnAnimationUpdate += OnAnimationUpdate;
#endif
        }
    }

    private void OnDestroy()
    {
#if DAYTIME_ANIMATION
        DayTimeAnimationDriver.OnAnimationUpdate -= OnAnimationUpdate;
#endif
    }

    public virtual void OnAnimationUpdate()
    {
        if (!mat)
        {
#if DAYTIME_ANIMATION
            DayTimeAnimationDriver.OnAnimationUpdate -= OnAnimationUpdate;
#endif
            return;
        }

    }

#if ! DAYTIME_ANIMATION
    /// <summary>
    /// 非动态昼夜系统，每帧直接更新属性
    /// </summary>
    void Update(){
        OnAnimationUpdate();
    }
#endif
}
