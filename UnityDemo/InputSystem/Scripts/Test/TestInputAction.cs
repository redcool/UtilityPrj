using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class TestInputAction : MonoBehaviour
{
    public InputAction movementAction;
    public float speed = 4;
    // Start is called before the first frame update
    void Start()
    {
        Application.targetFrameRate = 600;
        movementAction.Enable();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        var hv = movementAction.ReadValue<Vector2>();
        var dir = new Vector3(hv.x, 0, hv.y);
        transform.position += (speed * Time.fixedDeltaTime * dir);
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log(other);
    }
}
