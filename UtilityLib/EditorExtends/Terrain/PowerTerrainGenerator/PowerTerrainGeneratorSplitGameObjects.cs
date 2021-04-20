namespace PowerUtilities {
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using System.Linq;

#if UNITY_EDITOR
    using UnityEditor;
    using System.Text;
    using static PowerUtilities.PowerTerrainGeneratorSplitGameObjects;

    [CustomEditor(typeof(PowerTerrainGeneratorSplitGameObjects))]
    public class PowerTerrainGeneratorSplitGameObjectsEditor : Editor
    {

        public Dictionary<int, List<GameObject>> GroupTransforms(Transform[] children,Vector3 tileSize,int countInRow,TileSortMode sortMode)
        {
            var dict = new Dictionary<int, List<GameObject>>();
            foreach (var tr in children)
            {
                var pos = tr.position;
                var x = Mathf.FloorToInt(pos.x / tileSize.x);
                var z = Mathf.FloorToInt(pos.z / tileSize.z);
                var id = sortMode == TileSortMode.Column ? (z + x * countInRow) : (x + z * countInRow);

                if (!dict.ContainsKey(id))
                    dict.Add(id, new List<GameObject>());
                dict[id].Add(tr.gameObject);
            }

            return dict;
        }

        private static void ShowDict(Dictionary<int, List<GameObject>> dict)
        {
            foreach (var item in dict)
            {
                var names = item.Value.Select(item => item.name);
                var sb = new StringBuilder();
                foreach (var n in names)
                {
                    sb.Append(n);
                }
                Debug.Log($"{item.Key}:{sb} \n");
            }
        }


        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            var inst = target as PowerTerrainGeneratorSplitGameObjects;
            if (GUILayout.Button("Split"))
            {
                Split(inst);
            }

            if (GUILayout.Button("Clear Objects"))
            {
                Clear(inst.prefabs);
            }
        }

        private void Split(PowerTerrainGeneratorSplitGameObjects inst)
        {
            Transform[] trs = GetChildren(inst);
            var dict = GroupTransforms(trs, inst.tileSize, inst.countInRow, inst.tileSortMode);
            //ShowDict(dict);

            Undo.RegisterCompleteObjectUndo(inst.gameObject, "apply splited gameobjects");
            ApplyToTilePrefabs(inst.prefabs, dict);
        }

        private void Clear(GameObject[] prefabs)
        {
            if (prefabs == null)
                return;

            foreach (var prefab in prefabs)
            {
                PrefabTools.ModifyPrefab(prefab, prefabInst =>
                {
                    while (prefabInst.transform.childCount > 0)
                        DestroyImmediate(prefabInst.transform.GetChild(0).gameObject);
                });
            }
        }

        private void ApplyToTilePrefabs(GameObject[] prefabs, Dictionary<int, List<GameObject>> dict)
        {
            if (prefabs == null || dict == null)
                return;

            foreach (var item in dict)
            {
                var prefab = prefabs[item.Key];

                PrefabTools.ModifyPrefab(prefab, prefabInst =>
                {
                    foreach (var child in item.Value)
                    {
                        child.transform.SetParent(prefabInst.transform, true);
                    }
                });

            }
        }

        private static Transform[] GetChildren(PowerTerrainGeneratorSplitGameObjects inst)
        {
            var count = inst.transform.childCount;
            var trs = new Transform[count];
            for (int i = 0; i < count; i++)
            {
                trs[i] = inst.transform.GetChild(i);
            }

            return trs;
        }
    }
#endif


    public class PowerTerrainGeneratorSplitGameObjects : MonoBehaviour
    {
        public enum TileSortMode
        {
            Row = 1,Column = 2
        }
        public TileSortMode tileSortMode = TileSortMode.Column;
        public Vector3 tileSize = new Vector3(50,10,50);
        public int countInRow = 2;

        public GameObject[] prefabs;

    }
}