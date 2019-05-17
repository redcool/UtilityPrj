using UnityEngine;

public static class Texture2DEx
{
    public static void FillCircle(this Texture2D tex, Vector2Int center, int radius, Color c)
    {
        Vector2Int start = center - new Vector2Int(radius, radius);
        Vector2Int end = center + new Vector2Int(radius, radius);

        for (int i = start.x; i < end.x; i++)
        {
            for (int j = start.y; j < end.y; j++)
            {
                var p = new Vector2Int(i, j);
                var d = Vector2Int.Distance(p, center);

                if (d < radius)
                {
                    tex.SetPixel(i, j, c);
                }
            }
        }
    }

    public static void FillCircle(this Texture2D tex, Vector2Int center, Texture2D stamp)
    {
        var start = center - new Vector2Int(stamp.width / 2, stamp.height / 2);
        var block = new Vector2Int(stamp.width, stamp.height);
        var b1 = new BoundsInt(start.x,start.y,0,block.x,block.y,0);
        var b2 = new BoundsInt(0, 0, 0, tex.width, tex.height,0);
        b1.ClampToBounds(b2);

        var stampColor = stamp.GetPixels();
        var colors = tex.GetPixels(b1.x, b1.y, b1.size.x, b1.size.y);

        for (int i = 0; i < colors.Length; i++)
        {
            var c = colors[i];
            var mc = stampColor[i];
            colors[i] = c * mc;
        }
        tex.SetPixels(b1.x, b1.y, b1.size.x, b1.size.y, colors);
    }
}