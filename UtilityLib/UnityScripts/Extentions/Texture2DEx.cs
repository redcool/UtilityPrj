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

    public static void FillCircle(this Texture2D tex, Vector2Int center, Texture2D mask)
    {
        var start = center - new Vector2Int(mask.width / 2, mask.height / 2);
        var block = new Vector2Int(tex.width, tex.height) - start;
        block = new Vector2Int(Mathf.Min(block.x, mask.width), Mathf.Min(block.y, mask.height));

        var maskColors = mask.GetPixels();
        var colors = tex.GetPixels(start.x, start.y, block.x, block.y);

        for (int i = 0; i < colors.Length; i++)
        {
            var c = colors[i];
            var mc = maskColors[i];
            colors[i] = c * mc;
        }
        tex.SetPixels(start.x, start.y, block.x, block.y, colors);
    }
}