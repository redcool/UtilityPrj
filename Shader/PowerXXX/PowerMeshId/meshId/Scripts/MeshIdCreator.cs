namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using System.Linq;

#if UNITY_EDITOR
    using UnityEditor;
    [CustomEditor(typeof(MeshIdCreator))]
    public class MeshIdCreatorEditor : Editor
    {
        public Mesh CombineMeshes(Mesh[] meshes, string outputDir, string meshIdName, float unitWidth)
        {
            if (meshes == null || meshes.Length == 0)
                return null;

            var vertexList = new List<Vector3>();
            var indexList = new List<int>();
            var colorList = new List<Color32>();

            var uvList = new List<Vector2>();
            var uv2List = new List<Vector2>();
            var uv3List = new List<Vector2>();

            for (int i = 0; i < meshes.Length; i++)
            {
                var m = meshes[i];
                if (!m)
                    continue;


                var trianglesOffset = m.triangles.Select(index => index + vertexList.Count);
                indexList.AddRange(trianglesOffset.ToArray());

                var applyVertexOffset = m.vertices.Select(v =>
                {
                    v.x += unitWidth * i;
                    return v;
                });
                vertexList.AddRange(applyVertexOffset.ToArray());
                uvList.AddRange(m.uv);
                uv2List.AddRange(m.uv2);
                uv3List.AddRange(m.uv3);


                var colors = Enumerable.Repeat(new Color32((byte)i, 0, 0, 0), m.vertexCount);
                colorList.AddRange(colors.ToArray());
            }

            var mesh = new Mesh();
            mesh.vertices = vertexList.ToArray();
            mesh.triangles = indexList.ToArray();
            mesh.colors32 = colorList.ToArray();
            mesh.uv = uvList.ToArray();
            mesh.uv2 = uv2List.ToArray();
            mesh.uv3 = uv3List.ToArray();
            mesh.RecalculateNormals();

            var path = $"{outputDir}/{meshIdName}.asset";
            return CreateAndLoadAsset<Mesh>(mesh, path);
        }


        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            var inst = target as MeshIdCreator;

            if (GUILayout.Button("Create"))
            {
                if (string.IsNullOrEmpty(inst.outputDir))
                    inst.outputDir = "Assets";

                var meshes = inst.GetMeshes();

                var meshIdMesh = CombineMeshes(meshes, inst.outputDir, inst.meshIdName, inst.unitWidth);
                CreatePrefabs(meshIdMesh, inst.meshGos,inst.outputDir, inst.unitWidth,inst.meshIdShader,inst.destroyGameObjects);
            }


        }

        Material SaveMeshIdMaterial(Shader meshIdShader,string path)
        {
            if (!meshIdShader)
            {
                meshIdShader = Shader.Find("Unlit/MeshId");
            }

            var mat = new Material(meshIdShader);
            return CreateAndLoadAsset<Material>(mat, path);
        }

        void CreatePrefabs(Mesh meshIdMesh, GameObject[] originalGos,string outputDir, float unitWidth,Shader meshIdShader,bool destroyGameObjects)
        {
            var dir = CreateFolder(outputDir,"prefabs");

            var mat = SaveMeshIdMaterial(meshIdShader, $"{outputDir}/meshId.mat");

            for (int i = 0; i < originalGos.Length; i++)
            {
                var originalGo = originalGos[i];
                var prefabName = originalGo.name;

                GameObject meshIdGo = CreateMeshIdGo(meshIdMesh, unitWidth, mat, i, prefabName);

                var path = $"{dir}/{prefabName}.prefab";
                PrefabUtility.SaveAsPrefabAssetAndConnect(meshIdGo, path, InteractionMode.AutomatedAction);
                if(destroyGameObjects)
                    DestroyImmediate(meshIdGo);
            }
        }

        private static GameObject CreateMeshIdGo(Mesh meshIdMesh, float unitWidth, Material mat, int meshId, string prefabName)
        {
            var go = new GameObject(prefabName);
            var mf = go.AddComponent<MeshFilter>();
            mf.sharedMesh = meshIdMesh;

            var mr = go.AddComponent<MeshRenderer>();
            mr.sharedMaterial = mat;

            var blockSetter = go.AddComponent<MaterialPropertyBlockSetter>();
            blockSetter.infos = new[] {
                    new ShaderPropertyInfo{propName="_MeshId",floatPropValue = meshId},
                    new ShaderPropertyInfo{propName="_OffsetX",floatPropValue = -meshId * unitWidth},
                };
            blockSetter.UpdateInstancedProperties();
            return go;
        }

        public static string CreateFolder(string outputDir, string subFolderName)
        {
            var dir = $"{outputDir}/{subFolderName}";
            if (AssetDatabase.IsValidFolder(dir))
            {
                AssetDatabase.DeleteAsset(dir);
            }

            var guid = AssetDatabase.CreateFolder(outputDir, subFolderName);
            dir = AssetDatabase.GUIDToAssetPath(guid);
            return dir;
        }

        public static T CreateAndLoadAsset<T>(Object asset, string path) where T : Object
        {
            AssetDatabase.DeleteAsset(path);
            AssetDatabase.CreateAsset(asset, path);
            AssetDatabase.Refresh();

            return AssetDatabase.LoadAssetAtPath<T>(path);
        }
    }
#endif

    public class MeshIdCreator : MonoBehaviour
    {
        [Header("Output")]
        public float unitWidth = 4;
        public string outputDir = "Assets";
        [Header("Mesh info")]
        //public Mesh[] meshes;
        public GameObject[] meshGos;
        public string meshIdName = "TestMeshId";

        [Header("Prefab info")]
        public Shader meshIdShader;
        public bool destroyGameObjects = true;

        public Mesh[] GetMeshes()
        {
            var meshes = new Mesh[meshGos.Length];
            for (int i = 0; i < meshGos.Length; i++)
            {
                var go = meshGos[i];
                meshes[i] = go.GetComponent<MeshFilter>().sharedMesh;
            }
            return meshes;
        }
    }

}