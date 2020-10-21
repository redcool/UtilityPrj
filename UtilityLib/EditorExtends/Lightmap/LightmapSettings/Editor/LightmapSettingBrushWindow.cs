#if UNITY_EDITOR
using MyTools;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
using System.Linq;
using System;

public class LightmapSettingBrushWindow : EditorWindow
{
    bool isDrawMode;
    LayerMask targetLayer = 1;
    bool isMouseHold;
    float scaleValue = 1f;

    static HashSet<MeshRenderer> rendererSet = new HashSet<MeshRenderer>();

    [MenuItem("MyEditors/Window/LightmapSettingBrush")]
    static void Init()
    {
        var win = GetWindow<LightmapSettingBrushWindow>();
        win.Show();
    }

    private void OnEnable()
    {
        SceneView.onSceneGUIDelegate -= OnSceneGUI;
        SceneView.onSceneGUIDelegate += OnSceneGUI;
    }

    private void OnDisable()
    {
        SceneView.onSceneGUIDelegate -= OnSceneGUI;
    }

    private void OnGUI()
    {
        EditorGUILayout.HelpBox(".", MessageType.Info);

        EditorGUI.BeginChangeCheck();
        {
            var drawContent = new GUIContent("Enter Draw Mode", "When enter this mode nothing can selected");
            isDrawMode = EditorGUILayout.Toggle(drawContent, isDrawMode);

            targetLayer = EditorGUILayout.MaskField("Terrain Layer :", targetLayer, InternalEditorUtility.layers);
            scaleValue = EditorGUILayout.FloatField("Lightmap Scale : ", scaleValue);
        }
        if (EditorGUI.EndChangeCheck())
        {
            SceneView.RepaintAll();
        }
    }

    void OnSceneGUI(SceneView view)
    {
        var e = Event.current;

        SceneViewSelectNothing(isDrawMode);

        ShowFocusLine(isDrawMode,view);

        ProcessKeyUp(e, () => Repaint());

        ProcessMouseDrag(e, view, (mousePos) => ProcessRaycast(mousePos));

        ShowRenderers(r => {
            var scale = LightmapSettingTools.GetScaleInLightmap(r);
            Handles.color = Color.white * scale;
            Handles.DrawWireCube(r.bounds.center, r.bounds.size);
        });
    }

    void SceneViewSelectNothing(bool selectNothing)
    {
        if (selectNothing)
        {
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
        }
    }

    void ShowFocusLine(bool isDrawMode, SceneView view)
    {
        if (!isDrawMode)
        {
            return;
        }

        var w = view.position.width;
        var h = view.position.height;
        var size = 2;

        Handles.BeginGUI();
        var lastColor = GUI.color;
        GUI.color = Color.red;
        GUI.Box(new Rect(0, 0, w, size), "");
        GUI.Box(new Rect(0, h-20, w, size), "");
        GUI.Box(new Rect(1, 0, size, h), "");
        GUI.Box(new Rect(w-size, 0, size, h), "");

        GUI.color = lastColor;
        Handles.EndGUI();
    }
    void ShowRenderers(Action<MeshRenderer> action)
    {
        if (action == null)
            return;

        var lastColor = Handles.color;
        var list = rendererSet.ToArray();
        foreach (var r in list)
        {
            action(r);
        }
        Handles.color = lastColor;
    }

    void ProcessMouseDrag(Event e,SceneView view,Action<Vector2> whenOk)
    {
        if (e.type == EventType.MouseDrag
            && e.button == 0
            && view.position.Contains(e.mousePosition)
            && e.modifiers == EventModifiers.None
            )
        {
            whenOk(e.mousePosition);
        }
    }

    void ProcessKeyUp(Event e,Action action)
    {
        if (e.type != EventType.KeyUp)
            return;

        var value = e.keyCode == KeyCode.LeftBracket ? -0.1f : e.keyCode == KeyCode.RightBracket ? 0.1f : 0;
        scaleValue += value;
        scaleValue = Mathf.Max(0, scaleValue);

        if (value != 0 && action != null)
            action();
    }

    void ProcessRaycast(Vector3 mousePos)
    {
        var c = GetCollider(mousePos);
        if (!c)
            return;

        SetLightmapParamer(c);
        rendererSet.Add(c.GetComponent<MeshRenderer>());
    }

    Collider GetCollider(Vector3 mousePos)
    {
        var ray = HandleUtility.GUIPointToWorldRay(mousePos);

        RaycastHit hit;
        if(Physics.Raycast(ray,out hit, float.MaxValue, targetLayer))
        {
            Debug.Log(hit.collider);
            return hit.collider;
        }
        return null;
    }

    void SetLightmapParamer(Collider c)
    {
        if (!c)
            return;

        var mr = c.GetComponent<MeshRenderer>();
        if (!mr)
            return;

        EditorTools.AddStaticFlags(mr.gameObject, StaticEditorFlags.LightmapStatic);
        LightmapSettingTools.SetScaleInLightmap(mr, scaleValue);
    }
}
#endif