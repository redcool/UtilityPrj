using UnityEngine;
using System.Collections;
using UnityEditor;

public class ExportAssetBundle : MonoBehaviour {
    
    [MenuItem(AnalysisUtils.ANALYSIS_UTILS+"/BuildBundles")]
    static void Init()
    {
        BuildPipeline.BuildAssetBundles("Assets/../Bundles", BuildAssetBundleOptions.None, BuildTarget.Android);
    }
}
