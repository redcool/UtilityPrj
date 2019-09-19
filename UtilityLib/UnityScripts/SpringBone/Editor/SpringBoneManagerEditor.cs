#if UNITY_EDITOR

namespace UnityChan
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;

    [CustomEditor(typeof(SpringManager))]
    public class SpringBoneManagerEditor : Editor
    {
        SpringManager m;

        private void OnEnable()
        {
            m = target as SpringManager;
        }
        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            DrawDefaultInspector();

            GUILayout.BeginVertical("box");
            
            if(GUILayout.Button("Auto Config"))
            {
                m.AutoConfig();
            }
            GUILayout.EndVertical();

            serializedObject.ApplyModifiedProperties();
        }
    }
}
#endif