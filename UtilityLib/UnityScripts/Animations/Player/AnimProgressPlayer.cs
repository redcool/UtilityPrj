using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System;

#if UNITY_EDITOR
using UnityEditor;
[CustomEditor(typeof(AnimProgressPlayer))]
public class AnimProgressPlayerEditor : Editor
{
    
    public override void OnInspectorGUI()
    {
        var p = target as AnimProgressPlayer;

        EditorGUILayout.HelpBox("拖动滑块,手动播放 Animation clip", MessageType.Info);

        if (GUILayout.Button("Reset"))
        {
            p.Start();
        }

        base.OnInspectorGUI();
    }
}
#endif

[ExecuteAlways]
public class AnimProgressPlayer : MonoBehaviour
{
    public event Action<int> OnDayElapsed;
    public event Action<int> OnHourElapsed;

    public float timeOfDay = 100;
    [Range(0,1)]public float progress;
    public bool isManual;

    [Header("Debug Info")]
    public int day;

    [SerializeField]int hour;
    int lastHour;

    Animation anim;
    float speed;



    // Start is called before the first frame update
    internal void Start()
    {
        anim = GetComponent<Animation>();
        anim.playAutomatically = false;

        timeOfDay = Mathf.Max(1, timeOfDay);
        speed = 1f / timeOfDay;
    }

    private void Update()
    {
        if (!isManual)
        {
            UpdateTime();
        }

        PlayFirstClip();
    }

    private void UpdateTime()
    {
        progress += speed * Time.deltaTime;
        UpdateDay();
        progress %= 1f;

        UpadteHour();
    }

    private void UpadteHour()
    {
        hour = Mathf.FloorToInt(progress * 24);
        if (hour != lastHour)
        {
            lastHour = hour;
            if (OnHourElapsed != null)
                OnHourElapsed(lastHour);
        }
    }

    void UpdateDay()
    {
        if (progress >= 1)
            day++;
        if (OnDayElapsed != null)
            OnDayElapsed(day);
    }

    AnimationState GetFirstAnimationState()
    {
        if (!anim)
        {
            Debug.Log("Animation not exists!");
            return null;
        }
        TryApplyFirstClip();
        var state = anim[anim.clip.name];
        if (!state)
        {
            Debug.Log(anim.clip.name + " error.");
        }
        return state;
    }

    private void TryApplyFirstClip()
    {
        if (!anim.clip && anim.GetClipCount() > 0)
        {
            foreach (AnimationState item in anim)
            {
                if (!item)
                    continue;

                anim.clip = item.clip;
                break;
            }
        }
    }

    void PlayFirstClip()
    {
        var state = GetFirstAnimationState();
        if (!state)
        {
            return;
        }

        state.enabled = true;
        state.weight = 1;
        state.normalizedTime = progress;
        anim.Sample();
        state.enabled = false;
    }
}
