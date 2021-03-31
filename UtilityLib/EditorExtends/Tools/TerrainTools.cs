namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using System.Text;
    using System.Threading;
    using UnityEngine;
    public static class TerrainTools
    {
        public static void CopyFromTerrain(MeshRenderer mr, Terrain terrain)
        {
            mr.sharedMaterial = terrain.materialTemplate;
            mr.lightmapIndex = terrain.lightmapIndex;
            mr.lightmapScaleOffset = terrain.lightmapScaleOffset;
            mr.realtimeLightmapIndex = terrain.realtimeLightmapIndex;
            mr.realtimeLightmapScaleOffset = mr.realtimeLightmapScaleOffset;
        }
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

        public static Mesh GenerateTileMesh(Terrain terrain, RectInt heightmapRect, int resScale)
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

                    //Debug.DrawRay(pos, Vector3.up, Color.green,1);

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

        public static void GenerateWhole(Terrain terrain,Transform paretTr, int resScale = 1)
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

                    verts[vertexIndex] = Vector3.Scale(new Vector3(x, y, z), meshScale);
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

            var go = new GameObject("Terrain Mesh");
            go.transform.SetParent(paretTr, false);
            go.AddComponent<MeshFilter>().mesh = mesh;
            var mr = go.AddComponent<MeshRenderer>();
            CopyFromTerrain(mr, terrain);
        }


#endif

        public static void ApplyHeightmap(this TerrainData td, Texture2D tex)
        {
            if (!tex)
                return;

            var res = tex.width + 1;
            td.heightmapResolution = res;

            int w = tex.width;// (int)terrainSize.x;
            var heights = new float[res, res];
            var colors = tex.GetPixels();

            for (int y = 0; y < res; y++)
            {
                for (int x = 0; x < res; x++)
                {
                    var idX = x == 0 ? 0 : x - 1;
                    var idY = y == 0 ? 0 : y - 1;
                    heights[y, x] = colors[idX + idY * w].r;
                }
            }


            td.SetHeights(0, 0, heights);
        }

    }
}