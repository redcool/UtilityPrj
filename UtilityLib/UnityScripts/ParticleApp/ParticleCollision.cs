using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleCollision : MonoBehaviour
{
    public ParticleSystem ps;
    public float maxForce = 20;

    public List<ParticleCollisionEvent> collisionEvents = new List<ParticleCollisionEvent>();
    // Start is called before the first frame update
    void Start()
    {
        ps = GetComponent<ParticleSystem>();
    }

    void OnParticleCollision(GameObject other)
    {
        int numCollisionEvents = ps.GetCollisionEvents(other, collisionEvents);

        Rigidbody rb = other.GetComponent<Rigidbody>();
        int i = 0;

        while (i < numCollisionEvents)
        {
            if (rb)
            {
                var e = collisionEvents[i];
                
                Vector3 pos = e.intersection;
                Vector3 force = Vector3.ClampMagnitude(e.velocity,maxForce) ;
                //rb.AddForce(force);
                rb.AddForceAtPosition(force, pos);
            }
            i++;
        }
    }
}
