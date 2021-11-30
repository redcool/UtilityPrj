using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;

[CustomEditor(typeof(SHGen))]
public class SHGenEditor : Editor
{
    public override void OnInspectorGUI()
    {
        var inst = target as SHGen;
        if (!inst)
            return;
        base.OnInspectorGUI();

        GUILayout.BeginVertical("Box");
        if (GUILayout.Button("Bake SH 16"))
        {

            using (var buf = inst.CalcSH(SHGen.DEGREE, inst.shGenShader))
            {
                inst.bakedSHDatas = new Vector4[16];
                buf.GetData(inst.bakedSHDatas);
            }
            inst.OnEnable();
        }
        GUILayout.EndVertical();
    }
}
#endif

public class SHGen : MonoBehaviour
{
    public const int DEGREE = 3;
    public ComputeShader shGenShader;
    public Cubemap cubemap;
    public bool outputSHDatas;
    public Vector4[] bakedSHDatas;

    public void CalcSH(ComputeShader shGenShader,ComputeBuffer buffer,Cubemap cubemap,int coefNum=16)
    {
        var mainId = shGenShader.FindKernel("CSMain");
        shGenShader.SetBuffer(mainId, "RWSHBuffer", buffer);
        shGenShader.SetTexture(mainId, "_Cubemap", cubemap);

        shGenShader.Dispatch(mainId, coefNum, 1, 1);
    }

    public ComputeBuffer CalcSH(int degree, ComputeShader shGenShader)
    {
        var n = (degree + 1) * (degree + 1);
        var buf = new ComputeBuffer(n, 16);
        CalcSH(shGenShader, buf, cubemap, n);
        return buf;
    }

    // Start is called before the first frame update
    public void OnEnable()
    {
        var n = (DEGREE + 1) * (DEGREE + 1);
        var buf = new ComputeBuffer(n, 16);

        if (bakedSHDatas != null && bakedSHDatas.Length == 16)
        {
            buf.SetData(bakedSHDatas);
        }
        else
        {
            CalcSH(shGenShader, buf, cubemap, n);
        }

        Shader.SetGlobalBuffer("_SHBuffer", buf);

        if (outputSHDatas)
        {
            var datas = new Vector4[n];
            buf.GetData(datas);
            foreach (var item in datas)
            {
                Debug.Log(item);
            }
        }

    }

}
