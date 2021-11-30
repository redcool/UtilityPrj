using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TankWaveControl : MonoBehaviour
{
    public float speed = 4;

    RaycastHit[] hits = new RaycastHit[4];

    Vector3 rotDir;
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        var h = Input.GetAxis("Horizontal");
        var v = Input.GetAxis("Vertical");
        var dir = new Vector3(h, 0, v);
        dir = transform.rotation * dir;

        var pos = dir * speed * Time.deltaTime;

        var mx = Input.GetAxis("Mouse X");
        var my = Input.GetAxis("Mouse Y");

        rotDir.y += mx;

        var rayDir = -Vector3.up;
        var count = Physics.RaycastNonAlloc(transform.position,rayDir , hits, 100);
        if (count > 0)
        {
            var hit = hits[0];
            //pos += hit.point + Vector3.up;

            var rot = Quaternion.FromToRotation(Vector3.up,hit.normal);
            transform.localRotation = rot * Quaternion.Euler(rotDir);
        }
        transform.position = transform.position + pos;
    }
}
