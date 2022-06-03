using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class TestPlayerInput : MonoBehaviour
{
    Rigidbody rigid;
    PlayerInput playerInput;

    InputMaster inputMaster;
    public float speed=1;
    // Start is called before the first frame update
    void Start()
    {
        rigid = GetComponent<Rigidbody>();

        playerInput = GetComponent<PlayerInput>();
        inputMaster = new InputMaster();
        inputMaster.PlayerControl.Enable();
        inputMaster.PlayerControl.Jump.performed += OnJump;

        inputMaster.PlayerControl.Jump.Disable();
        inputMaster.PlayerControl.Jump.PerformInteractiveRebinding()
            .OnComplete(callback => {
                Debug.Log("complete");
                callback.Dispose();
                inputMaster.PlayerControl.Jump.Enable();
            })
            .Start();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        var hv = inputMaster.PlayerControl.Move.ReadValue<Vector2>();
        rigid.AddForce(new Vector3(hv.x, 0, hv.y)*speed);
    }

    public void OnJump(InputAction.CallbackContext context)
    {
        Debug.Log(context);
        rigid.AddForce(Vector3.up * 2, ForceMode.Impulse);
    }
}
