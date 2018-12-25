using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UtilityLib.Utils
{
    public class Fps : MonoBehaviour
    {
        private void OnGUI()
        {
            GUILayout.BeginArea(new Rect(Screen.width - 100, 0, 100, 40));
            GUILayout.Label(string.Format("FPS:{0:f2}", 1.0f / Time.smoothDeltaTime));
            GUILayout.EndArea();
        }
    }
}