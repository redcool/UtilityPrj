using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
/// <summary>
/// 1 渲染到 RenderTexture
/// 2 绘制RenderTexture到屏幕
/// </summary>
[ExecuteAlways]
public class CustomRender : MonoBehaviour
{
    public Mesh mesh;
    public Material material;

    public Vector3 from, to = Vector3.forward, up = Vector3.up;
    public float fov = 45, near = 0.3f, far = 1000;

    public bool createRT = true;

    RenderTexture rt;

    void Draw()
    {
        GL.Clear(true, true, Color.blue);
        GL.PushMatrix();

        LoadProjectionMatrix(transform.localToWorldMatrix);
        DrawMesh(mesh);

        DrawMesh(new[] { new Vector3(0, 0), new Vector3(0, 1), new Vector3(1, 1), new Vector3(1, 0) },
            new[] { new Vector2(0, 0), new Vector2(0, 1), new Vector2(1, 1), new Vector2(1, 0) },
            new[] { 0, 1, 2, 0, 2, 3 });

        GL.PopMatrix();
    }

    void LoadProjectionMatrix(float4x4 world)
    {
        var view = float4x4.LookAt(from, from + to, up);
        var projection = float4x4.PerspectiveFov(math.radians(fov), (float)Screen.width / Screen.height, near, far);
        GL.LoadProjectionMatrix(math.mul(projection, math.mul(view, world)));
    }

    void DrawRenderer(CustomRenderer cr)
    {
        if (!cr)
            return;

        cr.material.SetPass(0);
        DrawMesh(cr.mesh);
    }

    void DrawMesh(Mesh mesh)
    {
        var count = mesh.triangles.Length / 3;//0,3,1,3,0,2
        GL.Begin(GL.TRIANGLES);
        for (int i = 0; i < count; i++)
        {
            var v1 = mesh.triangles[i*3];
            var v2 = mesh.triangles[i*3 + 1];
            var v3 = mesh.triangles[i*3 + 2];


            GL.TexCoord(mesh.uv[v1]);
            GL.Vertex(mesh.vertices[v1]);

            GL.TexCoord(mesh.uv[v2]);
            GL.Vertex(mesh.vertices[v2]);

            GL.TexCoord(mesh.uv[v3]);
            GL.Vertex(mesh.vertices[v3]);

        }
        GL.End();

    }

    void DrawMesh(Vector3[] verts, Vector2[] uv, int[] triangles)
    {
        var count = triangles.Length / 3;
        GL.Begin(GL.TRIANGLES);
        for (int i = 0; i < count; i++)
        {
            var v1 = triangles[i * 3];
            var v2 = triangles[i*3 + 1];
            var v3 = triangles[i*3 + 2];

            GL.TexCoord(uv[v1]); GL.Vertex(verts[v1]);
            GL.TexCoord(uv[v2]); GL.Vertex(verts[v2]);
            GL.TexCoord(uv[v3]); GL.Vertex(verts[v3]);
        }
        GL.End();
    }

    void Update()
    {
        if (createRT)
        {
            rt = RenderTexture.GetTemporary(Screen.width, Screen.height, 24);
            createRT = false;
        }

        Graphics.SetRenderTarget(rt);

        material.SetPass(0);
        Draw();
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, Screen.width, Screen.height), rt);
    }
}
