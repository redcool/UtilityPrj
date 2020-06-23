namespace MyTools
{
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using System.Text;
    using System.Threading;
    using UnityEngine;
    public static class TerrainTools
    {


#if UNITY_2018_3_OR_NEWER
        public static void ExtractAlphaMapToPNG(Terrain terrain, string path)
        {
            var tex = GetBlendSplatMap(terrain);
            File.WriteAllBytes(path, tex.EncodeToPNG());
        }

        public static Texture2D GetBlendSplatMap(Terrain terrain)
        {
            var td = terrain.terrainData;

            var w = td.alphamapWidth;
            var h = td.alphamapHeight;
            var maps = td.GetAlphamaps(0, 0, w, h);

            var nx = 1f / w;
            var ny = 1f / h;

            var tex = new Texture2D(w, h, TextureFormat.RGBA32, true);
            for (int x = 0; x < w; x++)
            {
                for (int y = 0; y < h; y++)
                {
                    var finalColor = new Color();

                    for (int z = 0; z < td.alphamapLayers; z++)
                    {
                        var alpha = maps[y, x, z];
                        var layer = td.terrainLayers[z];
                        var tile = new Vector2(td.size.x, td.size.z) / layer.tileSize;

                        var diff = layer.diffuseTexture;

                        var u = x * nx * tile.x;
                        var v = y * ny * tile.y;

                        //var px = Mathf.FloorToInt(u * diff.width);
                        //var py = Mathf.FloorToInt(v * diff.height);
                        //var c = diff.GetPixel(px, py);

                        var c = diff.GetPixelBilinear(u, v);
                        finalColor += c * alpha;
                    }
                    tex.SetPixel(x, y, finalColor);
                }
            }

            return tex;
        }

        public static Mesh GenerateTileMesh(Terrain terrain, RectInt heightmapRect, Vector2 tileSize,int resScale)
        {
            var td = terrain.terrainData;
            var hw = heightmapRect.width;
            var hh = heightmapRect.height;

            var w = hw - 1;
            var h = hh - 1;
            var resolution = td.heightmapResolution - 1;
            Vector3 heightmapScale = new Vector3(tileSize.x / w * resScale, 1, tileSize.y / h * resScale);
            Vector2 uvScale = new Vector2(1f / resolution * resScale, 1f / resolution * resScale);

            hw = w / resScale + 1;
            hh = h / resScale + 1;
            w = hw - 1;
            h = hh - 1;

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
                    float y = td.GetHeight(offset.x * resScale, offset.y*resScale);
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
            mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
            mesh.vertices = verts;
            mesh.triangles = triangles;
            mesh.uv = uvs;
            mesh.RecalculateBounds();
            mesh.RecalculateNormals();
            mesh.RecalculateTangents();
            return mesh;
        }

        public static void GenerateWhole(Terrain terrain)
        {
            var td = terrain.terrainData;
            var hw = td.heightmapResolution;
            var hh = td.heightmapResolution;

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
            mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
            mesh.vertices = verts;
            mesh.triangles = triangles;
            mesh.uv = uvs;
            mesh.RecalculateBounds();
            mesh.RecalculateNormals();
            mesh.RecalculateTangents();

            var go = new GameObject("TerrainMesh");
            var mf = go.AddComponent<MeshFilter>();
            mf.sharedMesh = mesh;

            var mr = go.AddComponent<MeshRenderer>();
            Debug.Log(uvs[0] + ":" + uvs[uvs.Length - 1]);
        }

        public static void WriteObj(Mesh mesh,string filename)
        {
            var sw = new StreamWriter(filename);
            sw.WriteLine("# Untiy Terrain OBJ File");
            Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo("en-US");
            // vertices
            for (int i = 0; i < mesh.vertexCount; i++)
            {
                var v = mesh.vertices[i];
                //var sb = new StringBuilder("v ", 20);
                sw.WriteLine($"v {v.x} {v.y} {v.z}");
            }
            // uvs
            for (int i = 0; i < mesh.uv.Length; i++)
            {
                var uv = mesh.uv[i];
                sw.WriteLine($"vt {uv.x} {uv.y}");
            }
            // indices
            for (int i = 0; i < mesh.triangles.Length; i+=3)
            {
                var a = mesh.triangles[i] + 1;
                var b = mesh.triangles[i + 1] + 1;
                var c = mesh.triangles[i + 2] + 1;
                sw.WriteLine($"f {a}/{a} {b}/{b} {c}/{c}");
            }
            sw.Close();
        }
#endif

    }
}