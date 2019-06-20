using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimplePlayer : MonoBehaviour
{

    public float moveSpeed = 4;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Move();
        Rotate();
    }

    void Move()
    {
        var h = Input.GetAxis("Horizontal");
        var v = Input.GetAxis("Vertical");
        var dir = new Vector3(h, 0, v) * moveSpeed * Time.deltaTime;
        //dir = transform.TransformVector(dir);
        transform.position += dir;
        //transform.Translate(dir,Space.World);
    }

    void Rotate()
    {
        var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit))
        {
            var pos = hit.point - transform.position;
            pos.y = 0;

            transform.rotation = Quaternion.LookRotation(pos);
        }
    }
}
