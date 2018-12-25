//#define ETC
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UtilityLib.Cameras
{
    public class GyroCam : MonoBehaviour
    {
        public float speed = 4;

        Gyroscope gyro;
        // Use this for initialization
        void Start()
        {
            gyro = Input.gyro;
            gyro.enabled = true;
        }

        // Update is called once per frame
        void Update()
        {
            // rotate
            var rot = transform.rotation;
            if (Application.isMobilePlatform)
            {
                rot = Convert(gyro.attitude);
                transform.rotation = rot;
            }
#if ETC
            var h = ETCInput.GetAxis("Horizontal");
            var v = ETCInput.GetAxis("Vertical");
#else
            var h = Input.GetAxis("Horizontal");
            var v = Input.GetAxis("Vertical");
#endif

            // move 
            var dir = new Vector3(h, 0, v) * speed;
            //dir = Quaternion.Euler(0, rot.eulerAngles.y, 0) * dir;
            dir = transform.TransformDirection(dir);
            transform.Translate(dir * Time.deltaTime, Space.World);
            //Debug.DrawRay(transform.position, dir * 10);
        }

        private void OnGUI()
        {
            GUILayout.Box(Screen.orientation.ToString());
        }

        Quaternion Convert(Quaternion dq)
        {
            return Quaternion.Euler(90, 0, 0) * new Quaternion(-dq.x, -dq.y, dq.z, dq.w);
        }

    }
}