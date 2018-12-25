using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UtilityLib.Cameras
{
    public class FollowCam : MonoBehaviour
    {
        public Transform target;
        public Vector3 offset = new Vector3(0, 6, -6);
        public float smoothTime = 0.2f;

        public bool updateCamForward;
        // Use this for initialization
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {
            if (target)
            {
                Vector3 velocity = Vector3.zero;
                transform.position = Vector3.SmoothDamp(transform.position, target.position + offset, ref velocity, smoothTime);

                if (updateCamForward)
                    transform.forward = target.position - transform.position;
            }
        }
    }
}