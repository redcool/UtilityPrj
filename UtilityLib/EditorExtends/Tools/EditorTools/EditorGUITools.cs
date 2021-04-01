#if UNITY_EDITOR
namespace PowerUtilities
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEditorInternal;
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

        public static void BeginVerticalBox(Action drawAction,string style="Box")
        {
            EditorGUILayout.BeginVertical(style);
            if (drawAction != null)
                drawAction();
            EditorGUILayout.EndVertical();
        }

        public static int LayerMaskField(string label, int layers)
        {
            var tempLayers = InternalEditorUtility.LayerMaskToConcatenatedLayersMask(layers);
            tempLayers = EditorGUILayout.MaskField(label, tempLayers, InternalEditorUtility.layers);
            return InternalEditorUtility.ConcatenatedLayersMaskToLayerMask(tempLayers);
        }

        public static void DrawFoldContent(ref (string title, bool fold) foldInfo, Action drawContentAction)
        {
            DrawFoldContent(ref foldInfo, drawContentAction, GUI.contentColor);
        }

        public static void DrawFoldContent(ref (string title, bool fold) foldInfo, Action drawContentAction, Color titleColor, float space=8)
        {
            var originalColor = GUI.contentColor;
            GUI.contentColor = titleColor;

            foldInfo.fold = EditorGUILayout.Foldout(foldInfo.fold, foldInfo.title);
            GUI.contentColor = originalColor;

            if (foldInfo.fold)
            {
                drawContentAction();
            }
            EditorGUILayout.Space(space);
        }
    }
}
#endif