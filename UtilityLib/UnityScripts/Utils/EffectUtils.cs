using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UtilityLib.Utils
{
    public static class EffectUtils
    {
        public static void Play(string url, Transform parent, Vector3 localPos)
        {
            var p = ResourcesUtils.Load<GameObject>(url);
            if (p)
            {
                var inst = GameObject.Instantiate(p);
                inst.transform.SetParent(parent);
                inst.transform.localPosition = localPos;
            }
        }
    }
}