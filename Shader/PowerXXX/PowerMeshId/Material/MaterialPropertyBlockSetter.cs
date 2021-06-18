namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

#if UNITY_EDITOR
    using UnityEditor;
    using System.Linq;

    [CustomEditor(typeof(MaterialPropertyBlockSetter)), CanEditMultipleObjects]
    public class MaterialPropertyBlockSetterEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();


            if (GUILayout.Button("update"))
            {
                var q = targets.Select(obj => obj as MaterialPropertyBlockSetter);
                foreach (var item in q)
                {
                    item.UpdateInstancedProperties();
                }
            }
        }
    }
#endif

    public enum ShaderPropertyTypes
    {
        Float = 0,
        Color = 1,
        Vector = 2,
        Matrix = 3,
    }
    [System.Serializable]
    public class ShaderPropertyInfo
    {
        public string propName;
        public ShaderPropertyTypes type;

        public float floatPropValue;
        public Color colorPropValue;
        public Vector4 vectorPropValue;
        public Matrix4x4 matPropValue;
    }

    /// <summary>
    /// MaterialPropertyBlock setter
    /// </summary>
    [ExecuteAlways]
    public class MaterialPropertyBlockSetter: MonoBehaviour
    {
        public ShaderPropertyInfo[] infos;

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

            if (!render || infos == null)
                return;

            foreach (var info in infos)
            {
                if (string.IsNullOrEmpty(info.propName))
                    continue;

                switch (info.type)
                {
                    case ShaderPropertyTypes.Float: block.SetFloat(info.propName, info.floatPropValue); break;
                    case ShaderPropertyTypes.Color: block.SetColor(info.propName, info.colorPropValue); break;
                    case ShaderPropertyTypes.Matrix: block.SetMatrix(info.propName, info.matPropValue); break;
                    case ShaderPropertyTypes.Vector: block.SetVector(info.propName, info.vectorPropValue); break;
                }
            }
             
            render.SetPropertyBlock(block);
        }
    }

}