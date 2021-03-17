using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DaytimeAnimationMaterialFloat : BaseAnimationProperty
{
    public float propValue;
    public override void OnAnimationUpdate()
    {
        base.OnAnimationUpdate();
        if (mat)
        {
            mat.SetFloat(propName, propValue);
        }
    }
}
