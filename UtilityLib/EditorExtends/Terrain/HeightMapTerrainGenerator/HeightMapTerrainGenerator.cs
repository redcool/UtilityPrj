namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;


    /// <summary>
    /// Generate Terrains by Heightmaps 
    /// function : 
    /// 1 split heightmaps to tile heightmaps
    /// 2 generate terrain tile by heightmaps
    /// </summary>
    public class HeightMapTerrainGenerator : MonoBehaviour
    {
        [Header("Heightmap")]
        public Texture2D[] heightmaps;
        public TextureResolution heightMapResolution = TextureResolution.x256;

        [Header("Splited Heightmaps")]
        public List<Texture2D> splitTextureList;

        [Header("Terrain")]
        [Min(1)]public int countInRow = 1;
        public Vector3 terrainSize = new Vector3(1000,600,1000);
        [Min(0)]public int pixelError = 100;
        [Min(0)]public int updateTerrainId;
        public List<Terrain> generatedTerrainList;

        [Header("Material")]
        public Material materialTemplate;
        public TerrainLayer[] terrainLayers;

        public Texture2D[] controlMaps;
        public List<Texture2D> spliatedControlMaps;
        public TextureResolution controlMapResolution = TextureResolution.x256;
        [Min(1)]public int controlMapCountInRow;
    }
}