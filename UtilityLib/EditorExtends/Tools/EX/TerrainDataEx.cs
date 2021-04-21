﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Random = UnityEngine.Random;

namespace PowerUtilities
{
    public static class TerrainDataEx
    {
        public static void ApplyHeightmap(this TerrainData td, Texture2D heightmap,bool isGammaOn)
        {
            if (!heightmap)
                return;

            td.heightmapResolution = heightmap.width;

            BlitToHeightmap(td, heightmap,isGammaOn);

            //var w = heightmap.width;// (int)terrainSize.x;
            //var heights = new float[w, w];
            //var colors = heightmap.GetPixels();

            //for (int y = 0; y < w; y++)
            //{
            //    for (int x = 0; x < w; x++)
            //    {
            //        heights[y, x] = Mathf.GammaToLinearSpace(colors[x + y * w].r);
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

        public static void ResizeHeightmap(this TerrainData terrainData, int resolution)
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

        public const float normalizedHeightScale = 32765.0f / 65535.0f;
        public static void BlitToHeightmap(this TerrainData td, Texture2D heightmap,bool isGammaOn)
        {
            var blitMat = GetBlitHeightmapMaterial();
            blitMat.SetFloat("_Height_Offset", 0 * normalizedHeightScale);
            blitMat.SetFloat("_Height_Scale", normalizedHeightScale);
            blitMat.SetInt("_GammaOn", isGammaOn ? 1 : 0);
            Graphics.Blit(heightmap, td.heightmapTexture, blitMat);
            td.DirtyHeightmapRegion(new RectInt(0, 0, td.heightmapResolution, td.heightmapResolution), TerrainHeightmapSyncControl.HeightAndLod);
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
                Debug.Log(string.Format("Warning ! terrainData's alphamapLayers < {0}, need add terrainLayers!", controlMapLayers));
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
                            map[y, x, layerId] = colors[pixelX + pixelY * controlMapRes][layerId];

                        }
                    }
                }
            }
            td.SetAlphamaps(0, 0, map);
        }

        public static void CopyAlphamapsFrom(this TerrainData td, TerrainData from)
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
