namespace PowerUtilities {
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

#if UNITY_EDITOR
    using UnityEditor;
    using System.Linq;

    [CustomEditor(typeof(MeshIdPropertyBlock)), CanEditMultipleObjects]
    public class MeshIdPropertyBlockEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();


            if (GUILayout.Button("update"))
            {
                var q = targets.Select(obj => obj as MeshIdPropertyBlock);
                foreach (var item in q)
                {
                    item.UpdateInstancedProperties();
                }
            }
        }
    }
#endif


    [ExecuteAlways]
    public class MeshIdPropertyBlock : MonoBehaviour
    {
        public int meshId;
        public int depth;
        public float offsetX;

        public static MaterialPropertyBlock block;
        Renderer render;

        void Awake()
        {
            UpdateInstancedProperties();
        }

        public void UpdateInstancedProperties()
        {
            if (block == null)
                block = new MaterialPropertyBlock();

            if (!render)
                render = GetComponent<Renderer>();

            block.SetFloat("_MeshId", meshId);
            block.SetFloat("_Depth", depth);
            block.SetFloat("_OffsetX", offsetX);
            render.SetPropertyBlock(block);
        }
    }

}