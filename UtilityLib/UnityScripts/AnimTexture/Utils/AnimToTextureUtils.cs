using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class AnimToTextureUtils
{

    public static Texture2D BakeMeshToTexture(SkinnedMeshRenderer skin, GameObject clipGo, AnimationClip clip)
    {
        var width = skin.sharedMesh.vertexCount;
        var frameCount = (int)(clip.length * clip.frameRate);
        var timePerFrame = 1.0f / frameCount;
        var tex = new Texture2D(width, frameCount, TextureFormat.RGBAHalf, false, false);
        tex.name = clip.name;

        float time = 0;
        Mesh mesh = new Mesh();
        for (int i = 0; i < frameCount; i++)
        {
            clip.SampleAnimation(clipGo, time += timePerFrame);
            skin.BakeMesh(mesh);

            var colors = new Color[mesh.vertexCount];

            for (int j = 0; j < mesh.vertexCount; j++)
            {
                var v = mesh.vertices[j];
                colors[j] = new Vector4(v.x, v.y, v.z);
            }
            tex.SetPixels(0, i, width, 1, colors);
        }
        tex.Apply();
        return tex;
    }
}
