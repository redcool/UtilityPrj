using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ColliderTrigger : MonoBehaviour
{
    public UnityEvent OnTrigerEnterEvent;
    public UnityEvent OnTriggerExitEvent;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnTriggerEnter(Collider other)
    {
        OnTrigerEnterEvent.Invoke();
    }

    public void OnTriggerExit(Collider other)
    {
        OnTriggerExitEvent.Invoke();
    }
}
