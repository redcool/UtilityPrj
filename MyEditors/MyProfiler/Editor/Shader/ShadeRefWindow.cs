#if UNITY_EDITOR
namespace MyTools
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;
    using System.Linq;
    /// <summary>
    /// 显示该shader被使用的材质
    /// </summary>
    public class ShaderRefWindow : EditorWindow
    {

        [MenuItem(ShaderAnalysis.SHADER_ANALYSIS+"/Show Ref Window",priority =1)]
        static void Init()
        {
            var win = GetWindow<ShaderRefWindow>();
            win.Show();
        }

        private void OnSelectionChange()
        {
            Repaint();
        }

        public void OnGUI()
        {

            var shader = Selection.activeObject as Shader;

            if (!shader)
            {
                EditorGUILayout.HelpBox("Select a shader, show reference materilas", MessageType.Info);
                return;
            }

            var q = ShaderAnalysis.GetShaderInfo(shader);
            if (q == null)
                return;

            if (q.Count() == 0)
            {
                EditorGUILayout.LabelField("No Material used.");
            }

            GUILayout.BeginVertical("Box");
            q.ForEach(item =>
            {
                EditorGUILayout.ObjectField(item, typeof(Material), false);
            });
            GUILayout.EndVertical();
        }


    }
}
#endif