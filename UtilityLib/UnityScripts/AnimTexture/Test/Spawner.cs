using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UtilityLib.AnimTexture
{
    public class Spawner : MonoBehaviour
    {
        public GameObject[] prefabs;
        public int count = 10;
        public float radius = 10;
        public float y = 20;

        public float animSampleRate = 30f;
        public float startTime = 0;

        public bool isTest;
        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {
            if (isTest)
            {
                isTest = false;

                var block = new MaterialPropertyBlock();

                for (int i = 0; i < count; i++)
                {
                    var p = Instantiate(prefabs[Random.Range(0, prefabs.Length)], transform);

                    var pos = Random.insideUnitSphere * radius;
                    pos.y = Random.Range(-y, y);
                    p.transform.localPosition = pos;

                    var animTex = p.GetComponent<MeshRenderer>().sharedMaterial.GetTexture("_AnimTex");

                    var r = p.GetComponent<Renderer>();
                    var animLength = animTex.height / animSampleRate;
                    block.SetFloat("_StartTime", Random.Range(startTime, animLength));
                    block.SetFloat("_AnimSampleRate", Random.Range(10, animSampleRate));
                    r.SetPropertyBlock(block);
                }
            }
        }
    }
}