using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SHGen : MonoBehaviour
{
    public enum SH_TYPE
    {
        SH9 = 2,SH16 = 3
    }
    public SH_TYPE shType = SH_TYPE.SH9;
    public ComputeShader shGenShader;
    public Cubemap cubemap;
    
    // Start is called before the first frame update
    void OnEnable()
    {
        var degree = (int)shType;
        var n = (degree + 1) * (degree + 1);
        var buf = new ComputeBuffer(n, 16);

        var mainId = shGenShader.FindKernel("CSMain");
        shGenShader.SetBuffer(mainId, "RWSHBuffer", buf);
        shGenShader.SetTexture(mainId, "_Cubemap", cubemap);

        shGenShader.Dispatch(mainId, n, 1, 1);
        Shader.SetGlobalBuffer("_SHBuffer", buf);

        var datas = new Vector4[n];
        buf.GetData(datas);
        foreach (var item in datas)
        {
            Debug.Log(item);
        }
        //buf.Release();
    }

}
