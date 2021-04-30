namespace PowerUtilities
{
    using UnityEngine;
    using System.Collections;
    using UnityEngine.Events;

    public class Collider2DEvent : MonoBehaviour
    {
        public UnityEvent<Collision2D> onColliderEnter, onColliderExit, onColliderStay;

        private void OnCollisionStay2D(Collision2D collision)
        {
            onColliderStay.Invoke(collision);
        }

        private void OnCollisionExit2D(Collision2D collision)
        {
            onColliderExit.Invoke(collision);
        }
        private void OnCollisionEnter2D(Collision2D collision)
        {
            onColliderEnter.Invoke(collision);
        }
    }
}