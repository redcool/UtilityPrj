using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleGun : MonoBehaviour
{
    public ParticleSystem ps;
    public Transform gun;

    public float bulletSpeed = 100;
    public float timeInterval = 0.02f;
    float lastTime;

    public LayerMask layer;

    // Start is called before the first frame update
    void Start()
    {
        ps.Stop();

        var collision = ps.collision;
        collision.enabled = true;
        collision.lifetimeLoss = 1;
        collision.sendCollisionMessages = true;

    }

    // Update is called once per frame
    void Update()
    {

        if (Input.GetMouseButton(0) && (Time.time-lastTime > timeInterval))
        {
            lastTime = Time.time;

            Shoot();
        }

    }

    void Shoot()
    {
        var p = new ParticleSystem.EmitParams
        {
            position = gun.position,
            velocity = transform.forward * bulletSpeed,
        };
        ps.Emit(p,1);
    }


}
