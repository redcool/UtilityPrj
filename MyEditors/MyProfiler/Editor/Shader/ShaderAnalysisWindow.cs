#if UNITY_EDITOR
namespace MyTools
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;
    using System.Linq;

    public class ShaderAnalysisWindow : EditorWindow
    {
        List<ShaderAnalysis.ShaderMaterials> shaderQueue;
        List<ShaderAnalysis.ShaderMaterials> curPageList;

        static bool needUpdate;

        private Vector2 scrollPos;
        int count;

        [MenuItem(ShaderAnalysis.SHADER_ANALYSIS+"/shader分析窗口",priority =1)]
        static void Init()
        {
            var win = GetWindow<ShaderAnalysisWindow>();
            win.Show();
            needUpdate = true;
        }

        private void Update()
        {
            if (needUpdate)
            {
                needUpdate = false;

                shaderQueue = ShaderAnalysis.GetShaderInfos().ToList();
                count = shaderQueue.Count;
            }

        }

        private void OnGUI()
        {
            GUILayout.BeginVertical("Box");
            {
                GUILayout.BeginHorizontal("Box");
                {
                    if (GUILayout.Button("刷新"))
                    {
                        needUpdate = true;
                    }

                    EditorGUILayout.LabelField(string.Format("{0}", count));

                    GUILayout.EndHorizontal();
                }

                scrollPos = GUILayout.BeginScrollView(scrollPos, "Box");
                DrawShaderInfos();
                GUILayout.EndScrollView();

                GUILayout.EndVertical();
            }
        }

        void DrawShaderInfos()
        {
            if(shaderQueue == null)
            {
                return;
            }


            foreach (var item in shaderQueue)
            {
                // shader name, ref counts
                EditorGUI.indentLevel = 0;
                var count = item.materials.Count();

                EditorGUILayout.BeginVertical();
                {
                    EditorGUILayout.BeginHorizontal();
                    {
                        EditorGUILayout.ObjectField(item.shader, typeof(Shader), false, GUILayout.MinWidth(50));
                        EditorGUILayout.LabelField("count : " + count);
                        item.isFold = EditorGUILayout.Foldout(item.isFold,"");
                        EditorGUILayout.EndHorizontal();
                    }

                    // material objects
                    if (item.isFold)
                    {
                        EditorGUI.indentLevel++;

                        EditorGUILayout.BeginVertical();
                        {
                            foreach (var mat in item.materials)
                            {
                                EditorGUILayout.ObjectField(mat, typeof(Material), false);
                            }

                            EditorGUILayout.EndVertical();
                        }
                    }

                    EditorGUILayout.EndVertical();
                }
            }
        }
    }
}
#endif