namespace PowerUtilities
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Threading;
    using UnityEngine;
    using Object = UnityEngine.Object;
    using Random = UnityEngine.Random;

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

        public static void GenerateWhole(Terrain terrain, Transform paretTr, int resScale = 1)
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

        public static List<Terrain> GenerateTerrainsByHeightmaps(Transform rootTr, List<Texture2D> heightmaps,int heightmapScale, int countInRow, Vector3 terrainSize, Material materialTemplate)
        {
            if (heightmaps == null)
                return null;

            // cleanup
            foreach (Transform item in rootTr)
            {
                Object.DestroyImmediate(item.gameObject);
            }

            // calc rows
            var count = heightmaps.Count;
            var rows = count / countInRow;
            if (count % countInRow > 0)
                rows++;

            // get root go
            var terrainRootGo = new GameObject("Terrains");
            terrainRootGo.transform.SetParent(rootTr, false);

            // generate terrain go
            var heightMapId = 0;
            var terrainList = new List<Terrain>();
            for (int y = 0; y < rows; y++)
            {
                for (int x = 0; x < countInRow; x++)
                {
                    var go = new GameObject(string.Format("Terrain Tile [{0},{1}]", x, y));
                    var t = go.AddComponent<Terrain>();
                    terrainList.Add(t);

                    t.terrainData = new TerrainData();
                    t.terrainData.ApplyHeightmap(heightmaps[heightMapId++], heightmapScale);
                    t.terrainData.size = terrainSize;

                    t.transform.SetParent(terrainRootGo.transform, false);
                    t.transform.position = Vector3.Scale(terrainSize, new Vector3(x, 0, y));

                    var c = go.AddComponent<TerrainCollider>();
                    c.terrainData = t.terrainData;

                    t.materialTemplate = materialTemplate;
                }
                //break;
            }
            return terrainList;
        }

        public static void ApplyHeightmap(this TerrainData td, Texture2D heightmap,int heightmapResolutionScale=1)
        {
            if (!heightmap)
                return;

            var heightmapRes = heightmap.width * heightmapResolutionScale + 1;
            td.heightmapResolution = heightmapRes;

            BlitToHeightmap(td, heightmap);

            //int w = tex.width;// (int)terrainSize.x;
            //var heights = new float[heightmapRes, heightmapRes];
            //var colors = tex.GetPixels();

            //for (int y = 0; y < heightmapRes; y++)
            //{
            //    for (int x = 0; x < heightmapRes; x++)
            //    {
            //        var idX = x == 0 ? 0 : x - 1;
            //        var idY = y == 0 ? 0 : y - 1;

            //        // remap x,y
            //        idX = Mathf.FloorToInt((idX / (float)heightmapRes) * w );
            //        idY = Mathf.FloorToInt(idY / (float)heightmapRes * w);

            //        heights[y, x] = Mathf.LinearToGammaSpace(colors[idX + idY * w].r);
            //        //heights[y, x] = FilterColorBox(colors,idX,idY,w,w);
            //    }
            //}


            //td.SetHeights(0, 0, heights);
        }

        static Material GetBlitHeightmapMaterial()
        {
            //return new Material(Shader.Find("Hidden/TerrainTools/HeightBlit"));
            return new Material(Shader.Find("Hidden/Terrain/BlitTextureToHeightmap"));
        }



        public static void ResizeHeightmap(TerrainData terrainData, int resolution)
        {
            RenderTexture oldRT = RenderTexture.active;

            RenderTexture oldHeightmap = RenderTexture.GetTemporary(terrainData.heightmapTexture.descriptor);
            Graphics.Blit(terrainData.heightmapTexture, oldHeightmap);
#if UNITY_2019_3_OR_NEWER
            // terrain holes
            RenderTexture oldHoles = RenderTexture.GetTemporary(terrainData.holesTexture.width, terrainData.holesTexture.height);
            Graphics.Blit(terrainData.holesTexture, oldHoles);
#endif

            float sUV = 1.0f;
            int dWidth = terrainData.heightmapResolution;
            int sWidth = resolution;

            Vector3 oldSize = terrainData.size;
            terrainData.heightmapResolution = resolution;
            terrainData.size = oldSize;

            oldHeightmap.filterMode = FilterMode.Bilinear;

            // Make sure textures are offset correctly when resampling
            // tsuv = (suv * swidth - 0.5) / (swidth - 1)
            // duv = (tsuv(dwidth - 1) + 0.5) / dwidth
            // duv = (((suv * swidth - 0.5) / (swidth - 1)) * (dwidth - 1) + 0.5) / dwidth
            // k = (dwidth - 1) / (swidth - 1) / dwidth
            // duv = suv * (swidth * k)		+ 0.5 / dwidth - 0.5 * k

            float k = (dWidth - 1.0f) / (sWidth - 1.0f) / dWidth;
            float scaleX = sUV * (sWidth * k);
            float offsetX = (float)(0.5 / dWidth - 0.5 * k);
            Vector2 scale = new Vector2(scaleX, scaleX);
            Vector2 offset = new Vector2(offsetX, offsetX);

            Graphics.Blit(oldHeightmap, terrainData.heightmapTexture, scale, offset);
            RenderTexture.ReleaseTemporary(oldHeightmap);

#if UNITY_2019_3_OR_NEWER
            oldHoles.filterMode = FilterMode.Point;
            Graphics.Blit(oldHoles, (RenderTexture)terrainData.holesTexture);
            RenderTexture.ReleaseTemporary(oldHoles);
#endif

            RenderTexture.active = oldRT;

            terrainData.DirtyHeightmapRegion(new RectInt(0, 0, terrainData.heightmapTexture.width, terrainData.heightmapTexture.height), TerrainHeightmapSyncControl.HeightAndLod);
#if UNITY_2019_3_OR_NEWER
            terrainData.DirtyTextureRegion(TerrainData.HolesTextureName, new RectInt(0, 0, terrainData.holesTexture.width, terrainData.holesTexture.height), false);
#endif
        }

        public static float normalizedHeightScale => 32766.0f / 65535.0f;
        public static void BlitToHeightmap(this TerrainData td,Texture2D heightmap)
        {
            var blitMat = GetBlitHeightmapMaterial();
            //blitMat.SetFloat("_Height_Offset", 0 * kNormalizedHeightScale);
            blitMat.SetFloat("_Height_Scale", normalizedHeightScale);
            Graphics.Blit(heightmap, td.heightmapTexture, blitMat);
            td.DirtyHeightmapRegion(new RectInt(0, 0, td.heightmapResolution, td.heightmapResolution), TerrainHeightmapSyncControl.HeightAndLod);
             
            //ResizeHeightmap(td, 513);
        }

        static float FilterColorBox(Color[] colors,int coordX,int coordY,int width,int height)
        {
            float c = 0;
            for (int j = -1; j < 2; j++)
            {
                for (int i = -1; i < 2; i++)
                {
                    var x = coordX + i;
                    var y = coordY + j;
                    if (x < 0 || x >= width || y < 0 || y >= height)
                        continue;

                    c += Mathf.LinearToGammaSpace (colors[y * width + x].r);
                }
            }
            return c / 9;
        }

        /// <summary>
        /// 
        /// terrainData's alphamapLayers must >= controlMaps.length * 4
        /// 
        /// maps : 
        /// (y)</summary>br>
        /// *
        /// *         (alphamapLayers)
        /// *       *
        /// *     *
        /// *   *
        /// * *
        /// ***************(x)
        /// </summary>
        /// <param name="td"></param>
        /// <param name="controlMaps"></param>
        public static void ApplyAlphamaps(this TerrainData td, Texture2D[] controlMaps)
        {
            if (controlMaps == null || controlMaps.Length == 0)
                return;

            // check terrain layers
            var controlMapLayers = controlMaps.Length * 4;
            var terrainLayers = td.alphamapLayers;
            if (terrainLayers < controlMapLayers)
            {
                Debug.Log( string.Format("Warning ! terrainData's alphamapLayers < {0}, need add terrainLayers!", controlMapLayers));
            }

            controlMaps = controlMaps.Where(c => c).ToArray();

            var res = td.alphamapResolution;
            float[,,] map = new float[res, res, td.alphamapLayers];

            Vector2 uv = Vector2.one;

            for (int id = 0; id < controlMaps.Length; id++)
            {
                var controlMap = controlMaps[id];
                var colors = controlMap.GetPixels();
                var controlMapRes = controlMap.width;

                for (int y = 0; y < res; y++)
                {
                    uv.y = (float)y / res;
                    for (int x = 0; x < res; x++)
                    {
                        uv.x = (float)x / res;

                        // set alpha[x,y,z,w]
                        for (int layerId = 0; layerId < terrainLayers; layerId++)
                        {
                            var pixelX = (int)(uv.x * controlMapRes);
                            var pixelY = (int)(uv.y * controlMapRes);
                            map[y,x, layerId] = colors[pixelX + pixelY * controlMapRes][layerId];

                        }
                    }
                }
            }
            td.SetAlphamaps(0, 0, map);
        }

        public static void CopyAlphamapsFrom(this TerrainData td,TerrainData from)
        {
            if (!from)
                return;

            var maps = from.GetAlphamaps(0, 0, from.alphamapResolution, from.alphamapResolution);
            td.SetAlphamaps(0, 0, maps);
        }

        public static void AddAlphaNoise(this TerrainData td, float noiseScale)
        {
            float[,,] maps = td.GetAlphamaps(0, 0, td.alphamapWidth, td.alphamapHeight);

            for (int y = 0; y < td.alphamapHeight; y++)
            {
                for (int x = 0; x < td.alphamapWidth; x++)
                {
                    float a0 = maps[x, y, 0];
                    float a1 = maps[x, y, 1];

                    a0 += Random.value * noiseScale;
                    a1 += Random.value * noiseScale;

                    float total = a0 + a1;

                    maps[x, y, 0] = a0 / total;
                    maps[x, y, 1] = a1 / total;
                }
            }

            td.SetAlphamaps(0, 0, maps);
        }

    }
}
