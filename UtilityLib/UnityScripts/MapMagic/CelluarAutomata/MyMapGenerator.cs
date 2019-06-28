namespace CelluarAutomata
{
    using System.Collections.Generic;
    using UnityEngine;

    public class MyMapGenerator
    {
        public const int WALL = 255;
        public const int FLOOR = 0;

        int width;
        int height;
        int[,] map;
        int ratio;
        int seed;

        public MyMapGenerator(int width, int height)
        {
            this.width = width;
            this.height = height;
            map = new int[width, height];
        }

        public int[,] GenerateMap(int ratio = 40, int seed = 12345)
        {
            var random = new System.Random(seed);
            for (int x = 0; x < width; x++)
            {
                for (int y = 0; y < height; y++)
                {
                    if (x == 0 || y == 0 || x == width - 1 || y == height - 1)
                    {
                        map[x, y] = WALL;
                        continue;
                    }
                    map[x, y] = random.Next(0, 100) <= ratio ? WALL : FLOOR;
                }
            }

            for (int i = 0; i < 5; i++)
            {
                SmoothMap();
            }
            return map;
        }
        public void SmoothMap()
        {
            for (int x = 0; x < width; x++)
            {
                for (int y = 0; y < height; y++)
                {
                    var c = GetWallCount(x, y);
                    if (c > 4)
                        map[x, y] = WALL;
                    else if (c < 4)
                        map[x, y] = FLOOR;
                }
            }
        }

        public int GetWallCount(int x, int y)
        {
            var count = 0;
            for (int tx = x - 1; tx <= x + 1; tx++)
            {
                for (int ty = y - 1; ty <= y + 1; ty++)
                {
                    if (tx < 0 || tx >= width || ty < 0 || ty >= height)
                    {
                        count++;
                        continue;
                    }
                    if (tx == x && ty == y)
                        continue;
                    if (map[tx, ty] == WALL)
                        count++;
                }
            }
            return count;
        }

    }

}