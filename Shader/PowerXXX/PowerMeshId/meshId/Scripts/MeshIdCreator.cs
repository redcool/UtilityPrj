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
        public void CombineMeshes(Mesh[] meshes, string outputDir, string meshIdName, float unitWidth)
        {
            if (meshes == null || meshes.Length == 0)
                return;

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
            AssetDatabase.DeleteAsset(path);
            AssetDatabase.CreateAsset(mesh, path);
            AssetDatabase.Refresh();
        }
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            var inst = target as MeshIdCreator;

            if (GUILayout.Button("Create"))
            {
                if (string.IsNullOrEmpty(inst.outputDir))
                    inst.outputDir = "Assets/";

                var meshes = inst.GetMeshes();

                CombineMeshes(meshes, inst.outputDir, inst.meshIdName, inst.unitWidth);
            }
        }
    }
#endif

    public class MeshIdCreator : MonoBehaviour
    {
        //public Mesh[] meshes;
        public GameObject[] meshGos;
        public float unitWidth = 4;
        public string outputDir;
        public string meshIdName = "TestMeshId";

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