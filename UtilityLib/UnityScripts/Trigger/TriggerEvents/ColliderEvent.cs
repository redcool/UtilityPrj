namespace PowerUtilities
{
    using UnityEngine;
    using System.Collections;
    using UnityEngine.Events;

    public class ColliderEvent : MonoBehaviour
    {
        public UnityEvent<Collision> onCollisionEnter, onCollisionExit, onCollisionStay;

        private void OnCollisionEnter(Collision collision)
        {
            onCollisionEnter.Invoke(collision);
        }
        private void OnCollisionExit(Collision collision)
        {
            onCollisionExit.Invoke(collision);
        }

        private void OnCollisionStay(Collision collision)
        {
            onCollisionStay.Invoke(collision);
        }
    }
}