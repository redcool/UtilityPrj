namespace CelluarAutomata
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading.Tasks;
    using UnityEngine;

    public class MyMeshGenerator
    {
        int[,] map;
        MeshFilter mf;
        int width, height;

        List<Vector3> vertList = new List<Vector3>();
        List<int> triangleList = new List<int>();
        List<Vector2> uvList = new List<Vector2>();
        public void Show(MeshFilter mf, int[,] map, float size = 1)
        {
            vertList.Clear();
            triangleList.Clear();

            this.map = map;
            this.mf = mf;

            width = map.GetLength(0) - 1;
            height = map.GetLength(1) - 1;

            for (int x = 0; x < width; x++)
            {
                for (int y = 0; y < height; y++)
                {
                    var a = map[x, y + 1];
                    var b = map[x + 1, y + 1];
                    var c = map[x + 1, y];
                    var d = map[x, y];

                    var config = 0;
                    if (a == MyMapGenerator.WALL)
                        config += 1;
                    if (b == MyMapGenerator.WALL)
                        config += 2;
                    if (c == MyMapGenerator.WALL)
                        config += 4;
                    if (d == MyMapGenerator.WALL)
                        config += 8;

                    DrawSquare(config, x, y, size);
                }
            }



            var mesh = new Mesh();
            mesh.vertices = vertList.ToArray();
            mesh.triangles = triangleList.ToArray();
            mesh.uv = uvList.ToArray();
            mesh.RecalculateNormals();
            mf.mesh = mesh;
        }
        /// <summary>
        /// * * *
        /// *   *
        /// * * *
        /// </summary>
        /// <param name="config"></param>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="size"></param>
        void DrawSquare(int config, int x, int y, float size)
        {
            var lt = new Vector3(x, 0, y + 1) * size;
            var rt = new Vector3(x + 1, 0, y + 1) * size;
            var rb = new Vector3(x + 1, 0, y) * size;
            var lb = new Vector3(x, 0, y) * size;
            var ct = lt + Vector3.right * size * 0.5f;
            var cr = rb + Vector3.forward * size * 0.5f;
            var cb = lb + Vector3.right * size * 0.5f;
            var cl = lb + Vector3.forward * size * 0.5f;
            //Debug.DrawLine(lt, rt,Color.green,10);
            //Debug.DrawLine(rt, rb, Color.green, 10);
            //Debug.DrawLine(rb, lb, Color.green, 10);
            //Debug.DrawLine(lb, lt, Color.green, 10);
            //Debug.DrawLine(ct, cr, Color.green, 10);
            //Debug.DrawLine(cr, cb, Color.green, 10);
            //Debug.DrawLine(cb, cl, Color.green, 10);
            //Debug.DrawLine(cl, ct, Color.green, 10);

            switch (config)
            {
                case 0: break;
                //1
                case 1: DrawTriangle(lt, ct, cl); break;
                case 2: DrawTriangle(rt, cr, ct); break;
                case 4: DrawTriangle(rb, cb, cr); ; break;
                case 8: DrawTriangle(lb, cl, cb); break;
                ////2
                case 3: DrawTriangles(lt, rt, cr, cl); break;
                case 5: DrawTriangles(lt, ct, cr, rb, cb, cl); break;
                case 6: DrawTriangles(rt, rb, cb, ct); break;
                case 9: DrawTriangles(lb, lt, ct, cb); break;
                case 10: DrawTriangles(rt, cr, cb, lb, cl, ct); break;
                case 12: DrawTriangles(lb, cl, cr, rb); break;
                //3
                case 7: DrawTriangles(lt, rt, rb, cb, cl); break;
                case 11: DrawTriangles(lt, rt, cr, cb, lb); break;
                case 13: DrawTriangles(lb, lt, ct, cr, rb); break;
                case 14: DrawTriangles(lb, cl, ct, rt, rb); break;
                //4
                case 15: DrawTriangles(lt, rt, rb, lb); break;
            }

        }

        void DrawTriangle(params Vector3[] verts)
        {
            foreach (var item in verts)
            {
                triangleList.Add(vertList.Count);
                vertList.Add(item);
                uvList.Add(new Vector2(item.x / width, item.z / height) * 15);//15 :重复的次数
            }

        }

        void DrawTriangles(params Vector3[] verts)
        {
            if (verts.Length >= 3)
                DrawTriangle(verts[0], verts[1], verts[2]);
            if (verts.Length >= 4)
                DrawTriangle(verts[0], verts[2], verts[3]);
            if (verts.Length >= 5)
                DrawTriangle(verts[0], verts[3], verts[4]);
            if (verts.Length >= 6)
                DrawTriangle(verts[0], verts[4], verts[5]);

        }
    }

}