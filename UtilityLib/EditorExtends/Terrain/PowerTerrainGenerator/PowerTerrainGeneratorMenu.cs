#if UNITY_EDITOR
namespace PowerUtilities {
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;

    public class PowerTerrainGeneratorMenu
    {
        const string ROOT_PATH = "PowerUtilities";

        [MenuItem(ROOT_PATH + "/Terrain/Add PowerTerrainGenerator")]
        static void ShowMenu()
        {
            var go = Selection.activeGameObject;
            if (!go)
                return;

            go.GetOrAddComponent<PowerTerrainGenerator>();
        }
    }
}
#endif