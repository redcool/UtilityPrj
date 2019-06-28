using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Random = UnityEngine.Random;

namespace CelluarAutomata
{

    public class Region
    {
        public Color color = Random.ColorHSV(0, 1);
        public List<Vector2Int> coords = new List<Vector2Int>();
    }

    public class RegionFinder
    {
        int width;
        int height;
        int[,] map;
        public RegionFinder(int[,] map)
        {
            this.map = map;
            width = map.GetLength(0);
            height = map.GetLength(1);
        }
        public List<Region> FindRegions(int typeId)
        {
            var mapFlags = new int[width, height];
            //var closed = new List<Coord>();
            var regionList = new List<Region>();
            for (int x = 0; x < width; x++)
            {
                for (int y = 0; y < height; y++)
                {
                    var c = new Vector2Int { x = x, y = y };
                    //if(!closed.Contains(c) && map[x,y] == typeId)
                    if (mapFlags[x, y] == 0 && map[x, y] == typeId)
                    {
                        //closed.Add(c);

                        var region = FindRegion(c);
                        regionList.Add(region);
                        mapFlags[c.x, c.y] = 1;
                        foreach (var item in region.coords)
                        {
                            mapFlags[item.x, item.y] = 1;
                        }
                        //closed.AddRange(region.coords);
                    }
                }
            }
            return regionList;
        }

        public Region FindRegion(Vector2Int c)
        {
            var q = new Queue<Vector2Int>();
            q.Enqueue(c);

            var region = new Region();
            region.coords.Add(c);

            var typeId = map[c.x, c.y];
            var mapFlags = new int[width, height];
            //var closed = new HashSet<Coord>();
            while (q.Count > 0)
            {
                c = q.Dequeue();
                //if (!closed.Contains(c))
                if (mapFlags[c.x, c.y] == 0)
                {
                    //closed.Add(c);
                    mapFlags[c.x, c.y] = 1;

                    var l = c.x - 1;
                    var r = c.x + 1;
                    var up = c.y - 1;
                    var down = c.y + 1;

                    CheckCoord(new Vector2Int { x = l, y = c.y }, region, q, typeId);
                    CheckCoord(new Vector2Int { x = r, y = c.y }, region, q, typeId);
                    CheckCoord(new Vector2Int { x = c.x, y = up }, region, q, typeId);
                    CheckCoord(new Vector2Int { x = c.x, y = down }, region, q, typeId);
                }
            }
            return region;
        }
        void CheckCoord(Vector2Int c, Region region, Queue<Vector2Int> q, int typeId)
        {
            if (c.x >= 0 && c.x < width && c.y >= 0 && c.y < height)
            {
                if (map[c.x, c.y] == typeId)
                {
                    region.coords.Add(c);
                    q.Enqueue(c);
                }
            }
        }


    }
}
