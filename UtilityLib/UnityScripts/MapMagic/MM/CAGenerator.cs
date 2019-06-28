using MapMagic;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Tmp.MM
{
    [System.Serializable]
    [GeneratorMenu(menu ="CAGenerator",name ="CAGenerator",disengageable =true)]
    public class CAGenerator : Generator
    {
        MapGenerator mapGenerator = new MapGenerator();
        public Output output = new Output("map",InoutType.Map);
        public Output roomOutput = new Output("Rooms",InoutType.Map);
        public Output passageOutput = new Output("Passage", InoutType.Map);

        public float scale = 1;
        public int seed = 12345;
        public int ratio = 50;
        public int width = 128;
        public int height = 128;

        public override IEnumerable<Output> Outputs()
        {
            yield return output;
            yield return roomOutput;
            yield return passageOutput;
        }

        public override void Generate(CoordRect rect, Chunk.Results results, Chunk.Size terrainSize, int MMseed, Func<float, bool> stop = null)
        {
            if (stop != null && stop(0)) return;
            if (!enabled) return;

            var map = mapGenerator.GetMap(width,height, seed,ratio);
            var scaleX = (float)width / rect.size.x;
            var scaleZ = (float)height / rect.size.z;

            var matrix = new Matrix(rect);
            for (int x = rect.Min.x; x < rect.Max.x; x++)
            {
                for (int z = rect.Min.z; z < rect.Max.z; z++)
                {
                    var sx = (int)(x * scaleX % width);
                    var sz = (int)(z * scaleZ % height);
                    float t = map[sx, sz];

                    matrix[x, z] = 1f - (t / MapGenerator.MAX);
                    matrix[x, z] *= scale;
                }
            }

            var countX = Mathf.CeilToInt(1 / scaleX);
            var countZ = Mathf.CeilToInt(1 / scaleZ);

            // Rooms
            var roomMatrix = new Matrix(rect);
            foreach (var room in mapGenerator.survivingRooms)
            {

                foreach (var coord in room.tiles)
                {
                    for (int i = 0; i < countX; i++)
                    {
                        for (int j = 0; j < countZ; j++)
                        {
                            roomMatrix[coord.tileX * countX + i, coord.tileY * countZ + j] = 1;
                        }
                    }
                }
        }
            //  Passages
            var passageArr = new MapGenerator.Coord[mapGenerator.passageSet.Count];
            mapGenerator.passageSet.CopyTo(passageArr);
            var passageMatrix = new Matrix(rect);
            foreach (var c in passageArr)
            {
                for (int i = 0; i < countX; i++)
                {
                    for (int j = 0; j < countZ; j++)
                    {
                        passageMatrix[c.tileX * countX + i, c.tileY * countZ + j] = 1;
                    }
                }
            }

            if (stop != null && stop(0)) return;
            output.SetObject(results, matrix);
            roomOutput.SetObject(results, roomMatrix);
            passageOutput.SetObject(results, passageMatrix);
        }

        public override void OnGUI(GeneratorsAsset gens)
        {
            layout.Par(20); output.DrawIcon(layout, "Output");
            layout.Par(20); roomOutput.DrawIcon(layout,"Rooms");
            layout.Par(20); passageOutput.DrawIcon(layout, "Passages");

            layout.Field(ref scale, "Scale",min:0f,max:1f);
            layout.Field(ref seed, "Seed");
            layout.Field(ref ratio, "Ratio", min: 0, max: 100);
            layout.Field(ref width, "Width", min: 16, max: 256);
            layout.Field(ref height, "Height", min: 16, max: 256);
        }
    }
}
