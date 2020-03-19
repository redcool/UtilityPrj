using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

#if UNITY_EDITOR
using UnityEditor;
[CustomEditor(typeof(AnimProgressPlayer))]
public class AnimProgressPlayerEditor : Editor
{
    AnimationState targetState;
    public override void OnInspectorGUI()
    {
        EditorGUILayout.HelpBox("拖动滑块,手动播放 Animation clip", MessageType.Info);
        base.OnInspectorGUI();
    }
}
#endif

[ExecuteAlways]
public class AnimProgressPlayer : MonoBehaviour
{
    [Range(0,1)]public float progress;

    internal Animation anim;
    // Start is called before the first frame update
    void Start()
    {
        anim = GetComponent<Animation>();
    }

    // Update is called once per frame
    void Update()
    {
        if (!anim || !anim.clip)
        {
            return;
        }

        var state = anim[anim.clip.name];
        if (!state)
        {
            Debug.Log(anim.clip.name+" error.");
            return;
        }

        state.enabled = true;
        state.weight = 1;
        state.normalizedTime = progress;
        anim.Sample();
    }
}
