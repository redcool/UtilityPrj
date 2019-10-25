#if UNITY_EDITOR
using MyTools;
using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Text;

public class ShaderAnalysis {
    public class ShaderMaterials
    {
        public Shader shader;
        public IEnumerable<Material> materials;
    }

    public const string SHADER_ANALYSIS = "MyEditors/ShaderAnalysis";

    [MenuItem(SHADER_ANALYSIS+"/Anslysis All Shaders")]
    static void AnslysisAllShaders()
    {
        var sb = new StringBuilder();

        var q = GetShaderInfos();
        q.Select(item => string.Format("{0,-100} => {1} \n", item.shader, item.materials.Count()))
            .ForEach(item => sb.Append(item));

        Debug.Log(sb);
    }

    [MenuItem(SHADER_ANALYSIS+"/Select Unused Shaders")]
    static void SelectUnusedShaders()
    {
        var q = GetShaderInfos();
        var unusedQueue = q.Where(sm => sm.materials.Count() == 0)
            .Select(sm => sm.shader);

        Selection.objects = unusedQueue.ToArray();
    }

    [MenuItem(SHADER_ANALYSIS + "/Remove Unused Shaders")]
    static void RemoveUnusedShaders()
    {
        var q = GetShaderInfos();
        var unusedQueue = q.Where(sm => sm.materials.Count() == 0)
            .Select(sm => sm.shader)
            .Select(shader => AssetDatabase.GetAssetPath(shader));

        if(EditorUtility.DisplayDialog("Warning!","Deleted all unused shaders?", "ok"))
        {
            unusedQueue.ForEach(path => AssetDatabase.DeleteAsset(path));
        }
    }


    public static IEnumerable<ShaderMaterials> GetShaderInfos()
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

    public static IEnumerable<Material> GetShaderInfo(Shader shader)
    {
        if (!shader)
            return null;

        var mats = EditorTools.FindAssetsInProject<Material>();
        return mats.Where(mat => mat.shader == shader);
    }
}
#endif