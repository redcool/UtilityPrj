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

        public static Mesh GenerateTileMesh(Terrain terrain, RectInt heightmapRect, Vector2 tileSize, int resScale)
        {
            var td = terrain.terrainData;
            var meshScale = td.heightmapScale;
            meshScale.y = 1;

            //uv scale
            var hw = heightmapRect.width;
            var hh = heightmapRect.height;
            var resolution = heightmapRect.width - 1;

            var tileId = new Vector2(heightmapRect.x / (heightmapRect.width - 1), heightmapRect.y / (heightmapRect.height - 1));

            var uvTileCount = td.heightmapResolution / resolution;
            var uvTileRate = 1f / uvTileCount;
            var uvScale = new Vector2(uvTileRate / resolution * resScale, uvTileRate / resolution * resScale);

            // triangles 
            hh = (hh - 1) / resScale + 1;
            hw = (hw - 1) / resScale + 1;
            resolution /= resScale;

            //for (int z = 0; z < hh; z++)
            //{
            //    for (int x = 0; x < hw; x++)
            //    {
            //        var offsetX = (x * resScale + heightmapRect.x);
            //        var offsetZ = (z * resScale + heightmapRect.y);
            //        var y = td.GetHeight(offsetX * 1, offsetZ * 1);
            //        var pos = Vector3.Scale(new Vector3(offsetX, y, offsetZ), meshScale);
            //        Debug.DrawRay(pos, Vector3.up, Color.green, 1);
            //    }
            //}
            //return;

            //heightmapRect = new RectInt(0, 0, td.heightmapResolution, td.heightmapResolution);
            //resScale = 4;

            var verts = new Vector3[hw * hh];
            var uvs = new Vector2[verts.Length];
            var triangles = new int[resolution * resolution * 6];
            var vertexIndex = 0;
            var triangleIndex = 0;


            for (int z = 0; z < hh; z++)
            {
                for (int x = 0; x < hw; x++)
                {
                    var offsetX = x * resScale + heightmapRect.x;
                    var offsetZ = z * resScale + heightmapRect.y;

                    var y = td.GetHeight(offsetX, offsetZ);
                    var pos = Vector3.Scale(new Vector3(offsetX, y, offsetZ), meshScale);

                    verts[vertexIndex] = pos;
                    uvs[vertexIndex] = Vector2.Scale(new Vector2(x, z), uvScale) + tileId * uvTileRate;
                    vertexIndex++;

                    Debug.DrawRay(pos, Vector3.up, Color.green,1);

                    if (x < resolution && z < resolution)
                    {
                        /**
                         c d
                         a b
                         */
                        var a = z * hw + x;
                        var b = a + 1;
                        var c = (z + 1) * hw + x;
                        var d = c + 1;

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

        public static void GenerateWhole(Terrain terrain, Material mat, int resScale = 1)
        {
            var td = terrain.terrainData;
            var hw = td.heightmapResolution;
            var hh = td.heightmapResolution;
            var resolution = td.heightmapResolution - 1;

            var meshScale = td.heightmapScale * resScale;
            meshScale.y = 1;

            var uvScale = new Vector2(1f / resolution * resScale, 1f / resolution * resScale);

            hh = (hh - 1) / resScale + 1;
            hw = (hw - 1) / resScale + 1;
            resolution /= resScale;

            var verts = new Vector3[hw * hh];
            var uvs = new Vector2[verts.Length];
            var triangles = new int[resolution * resolution * 6];
            var vertexIndex = 0;
            var triangleIndex = 0;


            for (int z = 0; z < hh; z++)
            {
                for (int x = 0; x < hw; x++)
                {
                    var y = td.GetHeight(x * resScale, z * resScale);
                    var pos = Vector3.Scale(new Vector3(x, y, z), meshScale);

                    verts[vertexIndex] = pos;
                    uvs[vertexIndex] = Vector2.Scale(new Vector2(x, z), uvScale);
                    vertexIndex++;

                    if (x < resolution && z < resolution)
                    {
                        /**
                         c d
                         a b
                         */
                        var a = z * hw + x;
                        var b = a + 1;
                        var c = (z + 1) * hw + x;
                        var d = c + 1;

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
            go.AddComponent<MeshFilter>().mesh = mesh;
            go.AddComponent<MeshRenderer>().sharedMaterial = mat;
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