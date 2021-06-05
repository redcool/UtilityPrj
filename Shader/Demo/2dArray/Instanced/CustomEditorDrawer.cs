#if UNITY_EDITOR
namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEditor;
    using System;

    public abstract class CustomEditorDrawer<T> : Editor where T : class
    {
        public bool showDefaultUI;

        public override void OnInspectorGUI()
        {
            if (showDefaultUI)
                base.OnInspectorGUI();

            var inst = target as T;
            serializedObject.UpdateIfRequiredOrScript();
            DrawInspectorUI(inst);

            serializedObject.ApplyModifiedProperties();
        }

        public abstract void DrawInspectorUI(T inst);
    }
}
#endif