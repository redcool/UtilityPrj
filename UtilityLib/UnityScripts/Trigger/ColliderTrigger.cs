using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace TriggerUtils
{
    [Serializable]
    public class GameObjectUnityEvent : UnityEvent<GameObject> { }

    public class ColliderTrigger : MonoBehaviour
    {

        public GameObjectUnityEvent onEnter;
        public GameObjectUnityEvent onExit;
        public string targetTag = "Player";

        private void OnTriggerEnter(Collider other)
        {
            if(other.CompareTag(targetTag))
                onEnter?.Invoke(null);
        }

        private void OnTriggerExit(Collider other)
        {
            if (other.CompareTag(targetTag))
                onExit?.Invoke(null);
        }
    }

}