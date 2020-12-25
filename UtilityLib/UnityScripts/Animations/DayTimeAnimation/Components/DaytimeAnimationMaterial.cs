using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DaytimeAnimationMaterial : MonoBehaviour
{
    public Material mat;
    public string colorPropName = "_Color";
    [ColorUsage(true,true)]public Color color = Color.white;

    void Awake()
    {
        if(mat)
            DayTimeAnimationDriver.OnAnimationUpdate += DayTimeAnimationDriver_OnAnimationUpdate;
    }

    private void DayTimeAnimationDriver_OnAnimationUpdate()
    {
        if(!mat)
        {
            DayTimeAnimationDriver.OnAnimationUpdate -= DayTimeAnimationDriver_OnAnimationUpdate;
            return;
        }

        mat.SetColor(colorPropName,color);
    }
}
