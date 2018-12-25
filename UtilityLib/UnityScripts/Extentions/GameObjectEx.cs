using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UtilityLib.Extensions
{
    public static class GameObjectUtils
    {
        public static T GetOrAddComponent<T>(this GameObject go) where T : Component
        {
            var t = go.GetComponent<T>();
            if (!t)
                t = go.AddComponent<T>();
            return t;
        }

        public static T FindWithTag<T>(this GameObject go,string tag) where T : Component
        {
            var t = GameObject.FindWithTag(tag);
            if (!t)
                return default(T);

            return t.GetComponent<T>();
        }
    }
}