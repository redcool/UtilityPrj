using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class DaytimeAnimationMaterialColor : BaseAnimationProperty
{

    [ColorUsage(true,true)]public Color color = Color.white;


    public override void OnAnimationUpdate()
    {
        base.OnAnimationUpdate();

        if (mat)
            mat.SetColor(propName, color);
    }
}
