using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class ShowNeighbours : MonoBehaviour
{
    Terrain t;
    public Terrain left, right, top, bottom;
    // Start is called before the first frame update
    void Start()
    {
        t = GetComponent<Terrain>();
        if (!t)
            return;
        left = t.leftNeighbor;
        right = t.rightNeighbor;
        top = t.topNeighbor;
        bottom = t.bottomNeighbor;
    }

}
