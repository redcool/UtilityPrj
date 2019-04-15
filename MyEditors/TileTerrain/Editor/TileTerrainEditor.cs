using MyTools;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class TileTerrainEditor
{
    [MenuItem("MyEditors/Terrain/Command/GenerateTileTerrain")]
    static void Init()
    {
        if (Terrain.activeTerrain)
        {
            //GenerateWhole(Terrain.activeTerrain);

            var parentGo = new GameObject(Terrain.activeTerrain.name+"(Tiles)");
            var mat = AssetDatabase.LoadAssetAtPath<Material>("Assets/TileTerrain/Test.mat");
            var td = Terrain.activeTerrain.terrainData;
            GenerateTiles(td, 8, 8, parentGo.transform, mat);
        }
    }

    static void GenerateTiles(TerrainData td,int countX,int countZ,Transform parent,Material mat)
    {
        var sizeX = td.size.x / countX;
        var sizeZ = td.size.z / countZ;

        var sizeXHm = (td.heightmapWidth - 1) / countX;
        var sizeZHm = (td.heightmapHeight - 1) / countZ;

        for (int x = 0; x < countX; x++)
        {
            for (int z = 0; z < countZ; z++)
            {
                var rectInHeightmap = new RectInt(x * sizeXHm, z * sizeZHm, sizeXHm + 1, sizeZHm + 1);
                var tileMesh = GenerateTileMesh(Terrain.activeTerrain, rectInHeightmap, new Vector2(sizeX, sizeZ));

                GenerateTileGo(string.Format("Tile-{0}_{1}", x, z),tileMesh, parent, new Vector3(x * sizeX, 0, z * sizeZ), mat);
            }
        }
    }

    static void GenerateTileGo(string name,Mesh mesh,Transform parent,Vector3 worldPos,Material mat)
    {
        var tileGo = new GameObject(name);
        tileGo.transform.SetParent(parent);
        tileGo.transform.position = worldPos;

        var mr = tileGo.AddComponent<MeshRenderer>();
        mr.sharedMaterial = mat;

        var mf = tileGo.AddComponent<MeshFilter>();
        mf.sharedMesh = mesh;

        tileGo.AddComponent<MeshCollider>();
    }

    static Mesh GenerateTileMesh(Terrain terrain,RectInt heightmapRect,Vector2 tileSize)
    {
        var td = terrain.terrainData;
        var hw = heightmapRect.width;
        var hh = heightmapRect.height;

        var w = hw - 1;
        var h = hh - 1;
        var resolution = td.heightmapResolution - 1;
        //Vector3 heightmapScale = new Vector3(td.heightmapScale.x, 1, td.heightmapScale.z);
        Vector3 heightmapScale = new Vector3(tileSize.x / w, 1, tileSize.y / h);
        Vector2 uvScale = new Vector2(1f / resolution, 1f / resolution);

        Vector3[] verts = new Vector3[hw * hh];
        int[] triangles = new int[w * h * 6];
        Vector2[] uvs = new Vector2[verts.Length];

        int vertexIndex = 0;
        int triangleIndex = 0;
        for (int z = 0; z < hh; z++)
        {
            for (int x = 0; x < hw; x++)
            {
                var offset = new Vector2Int(x + heightmapRect.x, z + heightmapRect.y);
                float y = td.GetHeight(offset.x,offset.y);
                verts[vertexIndex] = Vector3.Scale(new Vector3(x, y, z), heightmapScale);
                uvs[vertexIndex] = Vector2.Scale(new Vector2(offset.x, offset.y), uvScale);
                vertexIndex++;

                /**
                 c d
                 a b
                 */
                if (x < w && z < h)
                {
                    int a = z * hw + x;
                    int b = a + 1;
                    int c = (z + 1) * hw + x;
                    int d = c + 1;

                    triangles[triangleIndex++] = a;
                    triangles[triangleIndex++] = c;
                    triangles[triangleIndex++] = d;

                    triangles[triangleIndex++] = a;
                    triangles[triangleIndex++] = d;
                    triangles[triangleIndex++] = b;
                }
            }
        }

        var mesh = new Mesh();
        mesh.vertices = verts;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateBounds();
        mesh.RecalculateNormals();
        //mesh.RecalculateTangents();
        return mesh;
    }

    static void GenerateWhole(Terrain terrain)
    {
        var td = terrain.terrainData;
        var hw = td.heightmapWidth;
        var hh = td.heightmapHeight;

        var resolution = td.heightmapResolution - 1;
        Vector3 heightmapScale = new Vector3(td.heightmapScale.x, 1, td.heightmapScale.z);
        Vector2 uvScale = new Vector2(1f / resolution, 1f / resolution);

        Vector3[] verts = new Vector3[hw * hh];
        int[] triangles = new int[resolution * resolution * 6];
        Vector2[] uvs = new Vector2[verts.Length];

        int vertexIndex = 0;
        int triangleIndex = 0;
        for (int z = 0; z < hh; z++)
        {
            for (int x = 0; x < hw; x++)
            {
                float y = td.GetHeight(x, z);
                verts[vertexIndex] = Vector3.Scale(new Vector3(x, y, z), heightmapScale);
                uvs[vertexIndex] = Vector2.Scale(new Vector2(x, z), uvScale);
                vertexIndex++;

                /**
                 c d
                 a b
                 */
                if (x < resolution && z < resolution)
                {
                    int a = z * hw + x;
                    int b = a + 1;
                    int c = (z + 1) * hw + x;
                    int d = c + 1;

                    triangles[triangleIndex++] = a;
                    triangles[triangleIndex++] = c;
                    triangles[triangleIndex++] = d;

                    triangles[triangleIndex++] = a;
                    triangles[triangleIndex++] = d;
                    triangles[triangleIndex++] = b;
                }
            }
        }

        var mesh = new Mesh();
        mesh.vertices = verts;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateBounds();
        mesh.RecalculateNormals();
        //mesh.RecalculateTangents();

        var go = new GameObject("TerrainMesh");
        var mf = go.AddComponent<MeshFilter>();
        mf.sharedMesh = mesh;

        var mr = go.AddComponent<MeshRenderer>();
        Debug.Log(uvs[0] + ":" + uvs[uvs.Length - 1]);
    }
}
