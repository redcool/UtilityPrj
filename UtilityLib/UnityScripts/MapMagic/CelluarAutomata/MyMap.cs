namespace CelluarAutomata
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class MyMap : MonoBehaviour
    {
        public int width = 40;
        public int height = 40;
        public int ratio = 40;
        public int seed;
        public MeshFilter mf;

        public bool showGizmos = true;
        public bool showMarchingSquare = false;

        int[,] map;

        MyMapGenerator mg;
        MyMeshGenerator meshGenerator;
        RegionFinder finder;
        RegionConnector connector;
        // Start is called before the first frame update
        void Start()
        {
            mg = new MyMapGenerator(width, height);
            meshGenerator = new MyMeshGenerator();
            map = mg.GenerateMap(ratio, seed);
            finder = new RegionFinder(map);
            connector = new RegionConnector(map);
            //meshGenerator.Show(mf, map);
        }

        private void Update()
        {
            if (Input.GetMouseButtonDown(0))
            {
                map = mg.GenerateMap(ratio, seed);

                if (showMarchingSquare)
                    meshGenerator.Show(GetComponentInChildren<MeshFilter>(), map);

                regions.Clear();
                //regions.Add(mg.FindRegion(new Coord(0, 0)));
                regions = finder.FindRegions(MyMapGenerator.FLOOR);

                connector.ConnectRegions(regions);
            }
        }

        List<Region> regions = new List<Region>();
        private void OnDrawGizmos()
        {
            if (map == null || !showGizmos)
                return;

            //for (int x = 0; x < width; x++)
            //{
            //    for (int y = 0; y < height; y++)
            //    {
            //        if (map[x, y] == MyMapGenerator.WALL)
            //            Gizmos.DrawCube(new Vector3(x, 0, y), Vector3.one * 0.9f);
            //    }
            //}
            foreach (var region in regions)
            {
                Gizmos.color = region.color;
                foreach (var c in region.coords)
                {
                    Gizmos.DrawCube(new Vector3(c.x, 0, c.y), Vector3.one * 0.9f);
                }
            }
        }
    }

}