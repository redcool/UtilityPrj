using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UtilityLib.Utils {
    public static class AudioSourceUtils
    {
        public static void PlayClipAtPoint(string url, Vector3 pos)
        {
            if (!string.IsNullOrEmpty(url))
            {
                var clip = ResourcesUtils.Load<AudioClip>(url);
                AudioSource.PlayClipAtPoint(clip,pos);
            }
        }
    }
}