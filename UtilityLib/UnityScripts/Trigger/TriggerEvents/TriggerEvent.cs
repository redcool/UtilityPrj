namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEngine.Events;

    public class TriggerEvent : MonoBehaviour
    {
        public UnityEvent<Collider> onTiggerEnter, onTriggerExit, onTriggerStay;


        void OnTriggerEnter(Collider other)
        {
            onTiggerEnter.Invoke(other);
        }
        void OnTriggerExit(Collider other)
        {
            onTriggerExit.Invoke(other);
        }

        void OnTriggerStay(Collider other)
        {
            onTriggerStay.Invoke(other);
        }
    }
}