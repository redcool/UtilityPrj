using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using System.Linq;

public class ScriptableRendererFeatureInstancer 
{
    static string instanceFolder = "Assets/URPFeatureAssets";
    [MenuItem("URP/Instance ScriptableRendererFeatures From Selection Folders")]
    static void InstanceScriptableRendererFeatures()
    {
        if (!AssetDatabase.IsValidFolder(instanceFolder))
        {
            AssetDatabase.CreateFolder("Assets", "URPFeatureAssets");
        }
        
        var scripts = Selection.GetFiltered<MonoScript>(SelectionMode.Assets | SelectionMode.DeepAssets);

        var q = scripts.Where(item => item.GetClass().IsSubclassOf( typeof(ScriptableRendererFeature)))
            .Select(item => item.GetClass());
        foreach (var itemType in q)
        {
            Debug.Log(itemType);
            var instance = ScriptableObject.CreateInstance(itemType);
            AssetDatabase.CreateAsset(instance, string.Format("{0}/{1}.asset",instanceFolder,itemType));
        }
    }
}
