using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

#if UNITY_EDITOR
using UnityEditor;
[CustomEditor(typeof(RenderToUV))]
public class RenderToUVEditor : Editor
{
    static Texture2D RenderToTexture(Mesh[] meshes,Material mat,int width=1024,int height=1024,bool wireframe=false)
    {
        if (meshes == null || meshes.Length == 0)
            throw new System.Exception("Meshes is empty.");

        var rect = new Rect(0, 0, 1f / meshes.Length - 0.001f, 0.5f - 0.001f);

        var rt = new RenderTexture(width, height, 16);
        Graphics.SetRenderTarget(rt);

        Render(meshes, mat, wireframe, rect);

        var tex = new Texture2D(width, height);
        tex.ReadPixels(new Rect(0, 0, width, height), 0, 0);
        Graphics.SetRenderTarget(null);
        return tex;

        static void Render(Mesh[] meshes, Material mat, bool wireframe, Rect rect)
        {
            GL.wireframe = wireframe;
            for (int i = 0; i < meshes.Length; i++)
            {
                rect.x = i * rect.width;

                var mesh = meshes[i];
                //mat.SetVector("uvOffset",new Vector4(rect.width,rect.height,rect.x,rect.y));
                mat.SetVector("uvOffset", new Vector4(1, 1, 0, 0));
                mat.SetPass(0);
                Graphics.DrawMeshNow(mesh, Vector3.zero, Quaternion.identity);
            }
            GL.wireframe = false;
        }
    }
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("Render"))
        {
            var inst = target as RenderToUV;
            var tex = RenderToTexture(inst.meshes, inst.mat,2048,512,true);
            File.WriteAllBytes(Application.dataPath + "/tex1.png", tex.EncodeToPNG());

            AssetDatabase.Refresh();
        }
    }
}
#endif

public class RenderToUV : MonoBehaviour
{
    public Mesh[] meshes;
    public Material mat;

}
