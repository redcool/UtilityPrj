using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticlePhy : MonoBehaviour
{
    public Transform[] trs;
    public ParticleSystem ps;

    // Start is called before the first frame update
    void Start()
    {
        trs = GetComponentsInChildren<Transform>();

        ps.Stop();

        foreach (var item in trs)
        {
            var emitParams = new ParticleSystem.EmitParams
            {
                position = item.position,
            };

            ps.Emit(emitParams, 1);
        }
    }

    // Update is called once per frame
    void Update()
    {
        ShowParticle();
    }

    void ShowParticle()
    {
        var particles = new ParticleSystem.Particle[trs.Length];
        var size = ps.GetParticles(particles);
        for (int i = 0; i < size; i++)
        {
            particles[i].position = trs[i].position;
        }
        ps.SetParticles(particles);
    }
}
