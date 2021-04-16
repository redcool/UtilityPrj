namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using System.Text;

#if UNITY_EDITOR
    using UnityEditor;
    [CustomEditor(typeof(TestHeight))]
    public class TestHeightEditor : Editor
    {
        TestHeight inst;

        bool isFold;
        public override void OnInspectorGUI()
        {
            inst = target as TestHeight;

            base.OnInspectorGUI();
            isFold = EditorGUILayout.BeginFoldoutHeaderGroup(isFold, "test");

            if (isFold)
                if (GUILayout.Button("Test"))
                {
                    inst.Generate();
                }
            EditorGUILayout.EndFoldoutHeaderGroup();

            if (GUILayout.Button("Check Colors"))
            {
                var sb = new StringBuilder();
                for (int i = 0; i < inst.texs.Length; i++)
                {
                    var tex = inst.texs[i];
                    var colors = tex.GetPixels();
                    sb.Clear();
                    foreach (var item in colors)
                    {
                        sb.AppendFormat(item.ToString());
                    }
                    Debug.Log(sb);
                }
            }
        }
    }
#endif

    public class TestHeight : MonoBehaviour
    {
        public GUISkin skin;
        public Texture2D tex;
        public Vector3 size = new Vector3(1000, 600, 1000);
        public int rowId;


        public Texture2D[] texs;
        // Start is called before the first frame update
        public void Generate()
        {
            var t = GetComponent<Terrain>();
            var td = t.terrainData;

            var w = tex.width;
            var res = w + 1;

            td.size = size;
            td.heightmapResolution = res;

            var heights = new float[res, res];
            var colors = tex.GetPixels();

            for (int y = 0; y < res; y++)
            {
                for (int x = 0; x < res; x++)
                {
                    var idX = x == 0 ? 0 : x - 1;
                    var idY = y == 0 ? 0 : y - 1;
                    heights[y, x] = colors[idX + idY * w].r;
                    if (x == rowId && y == 0)
                    {
                        Debug.Log(heights[y, x]);
                    }
                }
            }

            td.SetHeights(0, 0, heights);
        }


    }

}