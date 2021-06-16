using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestCulling : MonoBehaviour
{
    public GameObject prefab;
    public float sceneDistance = 50;

    public Camera cam;

    public float searchDistance = 3;
    public float[] boundingDistances = new[] { 3,6,9,float.PositiveInfinity};
    public int count = 5000;

    CullingGroup cullingGroup;

    Renderer[] renders;
    // Start is called before the first frame update
    void Start()
    {
        if (!cam)
            cam = Camera.main;


        cullingGroup = new CullingGroup();
        cullingGroup.targetCamera = cam;

        var spheres = new BoundingSphere[count];
        cullingGroup.SetBoundingSpheres(spheres);
        cullingGroup.SetBoundingSphereCount(count);
        cullingGroup.onStateChanged = onStateChanged;
        cullingGroup.SetBoundingDistances(boundingDistances);
        cullingGroup.SetDistanceReferencePoint(transform);

        renders = new Renderer[count];
        for (int i = 0; i < count; i++)
        {
            var pos = Random.insideUnitSphere * sceneDistance;
            var go = Instantiate(prefab, pos, Quaternion.identity);
            renders[i] = go.GetComponent<Renderer>();
            var r = go.GetComponent<MeshFilter>().sharedMesh.bounds.extents.x;

            spheres[i] = new BoundingSphere(pos, r);

        }
    }

    private void OnDestroy()
    {
        cullingGroup.onStateChanged = null;   
    }

    private void onStateChanged(CullingGroupEvent e)
    {
        if (!e.isVisible)
        {
            renders[e.index].material.color = (Color.gray);
            renders[e.index].enabled = false;
            return;
        }
        renders[e.index].enabled = true;
        if (e.currentDistance < boundingDistances.Length - 1)
        {
            renders[e.index].material.color = Color.green * e.currentDistance;
        }
        //if(e.currentDistance == 0)
        //{
        //    renders[e.index].material.color = Color.green;
        //}
        else
        {
            renders[e.index].material.color = Color.red;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
