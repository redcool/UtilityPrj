#if UNITY_EDITOR
using MyTools;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Text;

public class ShaderAnalysis {
    class ShaderMaterials
    {
        public Shader shader;
        public IEnumerable<Material> materials;
    }

    const string SHADER_ANALYSIS = "MyEditors/ShaderAnalysis/";

    [MenuItem(SHADER_ANALYSIS+"Anslysis All Shaders")]
    static void AnslysisAllShaders()
    {
        var sb = new StringBuilder();

        var q = GetShaderInfos();
        q.Select(item => string.Format("{0,-100} => {1} \n", item.shader, item.materials.Count()))
            .ForEach(item => sb.Append(item));

        Debug.Log(sb);
    }

    [MenuItem(SHADER_ANALYSIS+"Remove Unused Shaders")]
    static void RemoveUnusedShaders()
    {
        var q = GetShaderInfos();
        var unusedQueue = q.Where(sm => sm.materials.Count() == 0)
            .Select(sm => sm.shader);

        Selection.objects = unusedQueue.ToArray();
    }


    static IEnumerable<ShaderMaterials> GetShaderInfos()
    {
        var shaders = EditorTools.FindAssetsInProject<Shader>();
        var mats = EditorTools.FindAssetsInProject<Material>();

        var q = shaders.Select(shader => new ShaderMaterials
        {
            shader = shader,
            materials = mats.Where(mat => mat.shader == shader)
        });
        return q;
    }
}
#endif