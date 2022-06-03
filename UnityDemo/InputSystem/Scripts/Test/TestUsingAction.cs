using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Interactions;

public class TestUsingAction : MonoBehaviour
{
     InputMaster inputMaster;
    public bool useInputMaster;

    public float moveSpeed = 4;
    public float rotSpeed = 180;
    public Rigidbody projectile;

    public InputAction moveAction;
    public InputAction lookAction;
    public InputAction fireAction;
    public InputAction jumpAction;

    public Vector2 lookRotation;

    public float total;
    public float jumpSpeed = 4;
    public float jumpHeight;
    // Start is called before the first frame update
    void Start()
    {
        if (useInputMaster)
        {
            inputMaster = new InputMaster();
            inputMaster.Enable();
            moveAction = inputMaster.PlayerControl.Move;
            lookAction = inputMaster.PlayerControl.Look;
            jumpAction = inputMaster.PlayerControl.Jump;
            fireAction = inputMaster.PlayerControl.Fire;
        }
        moveAction.Enable();
        lookAction.Enable();
        fireAction.Enable();
        jumpAction.Enable();


        fireAction.canceled += c => { total = 0;
            total = 0;
        };
        fireAction.performed += c => {
            if (c.interaction is SlowTapInteraction)
            {
                total = (int)(c.duration * 2);
            }
            total = Mathf.Max(1, total);
            StartCoroutine( StartFire(total));
            total = 0;
        };

    }

    private IEnumerator StartFire(float total)
    {
        var delay = new WaitForSeconds(0.1f);
        for (int i = 0; i < total; i++)
        {
            var p = Instantiate(projectile, transform.position + new Vector3(0, 0, 0.4f), transform.rotation);
            p.AddForce(transform.forward * 20, ForceMode.Impulse);
            yield return delay;
        }
    }

    // Update is called once per frame
    void Update()
    {
        var dir = moveAction.ReadValue<Vector2>();
        var look = lookAction.ReadValue<Vector2>();

        Move(dir);
        Look(look);

    }


    private void Look(Vector2 look)
    {
        if (look.sqrMagnitude < 0.01f)
            return;

        look *= rotSpeed * Time.deltaTime;

        lookRotation.x -= look.y;
        lookRotation.x = Mathf.Clamp(lookRotation.x, -89, 89);
        lookRotation.y += look.x;
        lookRotation.y %= 360;

        //transform.localEulerAngles = lookRotation;
        transform.localRotation = Quaternion.Euler(lookRotation.x, lookRotation.y, 0);
    }



    private void Move(Vector2 dir)
    {
        //if (dir.sqrMagnitude < 0.01)
        //    return;
        var moveDir = Quaternion.Euler(0,transform.localEulerAngles.y,0) * new Vector3(dir.x, jumpHeight, dir.y);

        jumpHeight -= Time.deltaTime*10;
        if (jumpAction.triggered)
        {
            jumpHeight = jumpSpeed;
        }

        transform.position += moveSpeed * Time.deltaTime * moveDir;
        var pos = transform.position;
        pos.y = Mathf.Max(1, pos.y);
        transform.position = pos;
    }
}
