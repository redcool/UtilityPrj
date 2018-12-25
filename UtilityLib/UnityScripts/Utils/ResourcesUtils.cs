using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace UtilityLib.Utils
{
    public static class ResourcesUtils
    {
        static Dictionary<string, UnityEngine.Object> dict = new Dictionary<string, UnityEngine.Object>();

        public static T Load<T>(string url) where T : UnityEngine.Object
        {
            if (string.IsNullOrEmpty(url))
                return default(T);

            if (!dict.ContainsKey(url))
            {
                dict[url] = Resources.Load<T>(url);
            }
            return dict[url] as T;
        }

        public static void Unload(string url)
        {
            if (!string.IsNullOrEmpty(url))
            {
                if (dict.ContainsKey(url))
                    Resources.UnloadAsset(dict[url]);
            }
        }
    }
}