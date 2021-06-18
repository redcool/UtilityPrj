using PowerUtilities;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
[CustomEditor(typeof(TestInstancedBlock))]
public class TestInstancedBlockEditor : Editor
{

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var inst = target as TestInstancedBlock;
        if (GUILayout.Button("Update"))
        {
            inst.UpdateBlock();
        }
    }

}


#endif
public class TestInstancedBlock : MonoBehaviour
{
    public int depth;
    MaterialPropertyBlock block;
    Renderer r;
    // Start is called before the first frame update
    void Start()
    {
        UpdateBlock();
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void UpdateBlock()
    {
        if (block == null)
            block = new MaterialPropertyBlock();
        if (!r)
            r = GetComponent<Renderer>();

        if (block != null)
        {
            block.SetFloat("_Depth", depth);
            r.SetPropertyBlock(block);
        }
    }
}
