#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ProbeSettings))]
public class ProbeSettingsEditor : Editor {
    private void OnEnable()
    {
        var t = target as ProbeSettings;
        t.ReplaceProbes();
    }
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        var t = target as ProbeSettings;

        if(GUILayout.Button("Replace Probes"))
        {
            t.ReplaceProbes();
        }

    }
}
#endif