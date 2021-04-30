namespace PowerUtilities
{
    using UnityEngine;
    using System.Collections;
    using UnityEngine.Events;

    public class Trigger2DEvent : MonoBehaviour
    {
        public UnityEvent<Collider2D> onTriggerEnter, onTriggerExit, onTriggerStay;

        private void OnTriggerEnter2D(Collider2D collision)
        {
            onTriggerEnter.Invoke(collision);
        }

        private void OnTriggerExit2D(Collider2D collision)
        {
            onTriggerExit.Invoke(collision);
        }

        private void OnTriggerStay2D(Collider2D collision)
        {
            onTriggerStay.Invoke(collision);
        }
    }
}