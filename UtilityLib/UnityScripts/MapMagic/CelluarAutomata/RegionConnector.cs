using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace CelluarAutomata
{
    public class RegionConnector
    {
        int width;
        int height;
        int[,] map;
        public RegionConnector(int[,] map)
        {
            this.map = map;
            width = map.GetLength(0);
            height = map.GetLength(1);
        }

        Vector2Int FindRegionBorder(Region region, Vector2Int regionCenter,Vector2Int targetCenter)
        {
            var coords = region.coords.Select(a => a).ToList();
            coords.Sort((a, b) => (a - targetCenter + a - regionCenter).sqrMagnitude - (b - targetCenter + b -regionCenter).sqrMagnitude);
            return coords[0];
        }

        Vector2Int FindRegionCenter(Region region)
        {
            var coords =  region.coords.Select((a) => a).ToList();
            coords.Sort((a, b) => a.sqrMagnitude - b.sqrMagnitude);

            var min = coords[0];
            var max = coords[coords.Count - 1];
            var c = max - min;
            coords.Sort((a, b) => ((a - c).sqrMagnitude - (b - c).sqrMagnitude));
            return coords[0];
        }

        List<Vector2Int> Link2Center(Region regionA,Region regionB)
        {
            var centerA = FindRegionCenter(regionA);
            var centerB = FindRegionCenter(regionB);

            var list = FindPath(centerA, centerB);
            for (int i = 1; i < list.Count; i++)
            {
                var p1 = list[i-1];
                var p2 = list[i];
                Debug.DrawLine(new Vector3(p1.x,0,p1.y), new Vector3(p2.x,0,p2.y), Color.green, 5);
            }

            return null;
        }

        List<Vector2Int> FindPath(Vector2Int from,Vector2Int to)
        {
            var list = new List<Vector2Int>();
            var closedSet = new HashSet<Vector2Int>();

            var refPos = from;
            var isDone = false;
            while (!isDone)
            {
                var dist = (to - refPos).sqrMagnitude;

                for (int i = -1; i < 2; i++)
                {
                    for (int j = -1; j < 2; j++)
                    {
                        var p = refPos + new Vector2Int(i, j);
                        if(p == to)
                        {
                            isDone = true;
                            return list;
                        }

                        if (closedSet.Contains(p))
                            continue;
                        closedSet.Add(p);

                        var curDist = (to - p).sqrMagnitude;
                        if (curDist < dist)
                        {
                            refPos = p;
                            dist = curDist;
                        }
                    }
                }

                list.Add(refPos);
            }
            return list;
        }


        /// <summary>
        /// a -> b -> c
        /// </summary>
        /// <param name="regionList"></param>
        public void ConnectRegions(List<Region> regionList)
        {
            if (regionList.Count < 2)
                return;
            for (int i = 1; i < regionList.Count; i++)
            {
                var a = regionList[i - 1];
                var b = regionList[i];
                Link2Center(a, b);
            }
        }
    }
}
