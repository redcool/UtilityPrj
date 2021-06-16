using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
[CustomEditor(typeof(SimpleShock))]
public class SimpleShockEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        var inst = target as SimpleShock;
        if (!inst)
            return;

        if (GUILayout.Button("Restart"))
        {
            inst.Restart();
        }
    }
}
#endif

public class SimpleShock : MonoBehaviour
{
    [Min(0.001f)]public float time = 3;
    public float intensity = 1;

    float attenSpeed;
    float atten = 1;
    Vector3 originalPos;

    // Start is called before the first frame update
    void Start()
    {
        attenSpeed = 1 / time;
        originalPos = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        atten -= attenSpeed * Time.deltaTime;
        atten = Mathf.Clamp01(atten);

        var randomPos = originalPos + Random.insideUnitSphere * intensity * atten;
        transform.position = randomPos;

        if (atten <= 0)
            enabled = false;
    }

    public void Restart()
    {
        enabled = true;
        atten = 1;
        attenSpeed = 1 / time;
    }
}
