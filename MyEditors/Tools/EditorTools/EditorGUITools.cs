#if UNITY_EDITOR
namespace MyTools
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;

    public static class EditorGUITools
    {
        public static void DrawPreview(Texture tex)
        {
            var rect = GUILayoutUtility.GetRect(100, 100, "Box");
            EditorGUI.DrawPreviewTexture(rect, tex);
        }

        public static void DrawSplitter(float w, float h)
        {
            GUILayout.Box("", GUILayout.Height(h), GUILayout.Width(w));
        }

        public static void DrawFixedWidthLabel(float width, Action drawAction)
        {
            if (drawAction == null)
                return;

            var lastLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = width;
            drawAction();
            EditorGUIUtility.labelWidth = lastLabelWidth;
        }
    }
}
#endif