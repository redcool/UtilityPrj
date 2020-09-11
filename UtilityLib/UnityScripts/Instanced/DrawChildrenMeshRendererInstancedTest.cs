using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawChildrenMeshRendererInstancedTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        DrawChildrenMeshRendererInstanced.OnInit += DrawChildrenMeshRendererInstanced_OnInit;
    }

    private void DrawChildrenMeshRendererInstanced_OnInit(DrawChildrenMeshRendererInstanced obj)
    {
        obj.culledRatio = 0.1f;
        obj.forceRefresh = true;
    }

}
