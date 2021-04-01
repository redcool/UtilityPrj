using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class TestAlphamap : MonoBehaviour
{
    public TerrainLayer[] terrayLayers;
    
    // Add some random "noise" to the alphamaps.
    void AddAlphaNoise(Terrain t, float noiseScale)
    {

        var td = t.terrainData;
        td.terrainLayers = terrayLayers;

        float[,,] maps = t.terrainData.GetAlphamaps(0, 0, t.terrainData.alphamapWidth, t.terrainData.alphamapHeight);
        
        for (int y = 0; y < t.terrainData.alphamapHeight; y++)
        {
            for (int x = 0; x < t.terrainData.alphamapWidth; x++)
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

        t.terrainData.SetAlphamaps(0, 0, maps);
    }

    private void Start()
    {
        var t = GetComponent<Terrain>();
        AddAlphaNoise(t, 10);
    }
}