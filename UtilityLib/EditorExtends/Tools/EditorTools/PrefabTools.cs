namespace PowerUtilities
{
#if UNITY_EDITOR
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;

    public static class PrefabTools
    {
        public static void RenamePrefab(GameObject instance,string newName)
        {
            if (!instance)
                return;

            // rename prefab'name
            var p = PrefabUtility.GetCorrespondingObjectFromOriginalSource(instance);
            if (p)
            {
                var path = AssetDatabase.GetAssetPath(p);
                AssetDatabase.RenameAsset(path, newName);
            }
        }
    }
#endif
}