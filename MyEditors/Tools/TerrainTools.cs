namespace MyTools
{
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
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
#endif

    }
}