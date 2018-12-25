#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Linq;
using System.IO;

namespace UtilityLib.AnimTexture {
    public class AnimToTexture
    {
        const string DEFAULT_TEX_DIR = "AnimTexPath";
        [MenuItem("UtilityLib/AnimToTexture/BakeAnimToTexture")]
        static void Init()
        {
            var objs = Selection.GetFiltered<Object>(SelectionMode.DeepAssets);

            var q = from obj in objs
                    let go = obj as GameObject
                    where go
                    select go;

            foreach (var item in q)
            {
                var newInst = Object.Instantiate(item);
                newInst.name = item.name;

                Bake(newInst);
                Object.DestroyImmediate(newInst);
            }
            Debug.Log("Bake done.");
            Selection.activeObject = AssetDatabase.LoadAssetAtPath($"Assets/{DEFAULT_TEX_DIR}", typeof(Object));
        }

        public static void Bake(GameObject go)
        {
            var skin = go.GetComponentInChildren<SkinnedMeshRenderer>();
            var anim = go.GetComponentInChildren<Animation>();
            var dir = $"{Application.dataPath}/{DEFAULT_TEX_DIR}/";
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            foreach (AnimationState state in anim)
            {
                var tex = AnimToTextureUtils.BakeMeshToTexture(skin, go, state.clip);
                AssetDatabase.CreateAsset(tex, $"Assets/{DEFAULT_TEX_DIR}/{tex.name}.asset");
            }
            AssetDatabase.Refresh();
        }
    }
}
#endif