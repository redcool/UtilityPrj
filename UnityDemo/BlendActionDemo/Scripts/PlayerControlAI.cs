using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerControlAI : MonoBehaviour
{
    public CharacterController cc;
    public float moveSpeed = 4;
    float speed = 4;

    public float jumpSpeed = 8;
    public float gravity = -10;
    public float rotateSpeed = 120;

    public Vector3 moveDir;

    public Camera cam;
    public Vector3 moveDirInCameraSpace;
    public float eulerYDelta;
    float lastEulerY;

    public Transform attackTarget;

    // Start is called before the first frame update
    void Start()
    {
        cc = GetComponent<CharacterController>();
        cam = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        MoveCharacter(ref moveDir, out moveDirInCameraSpace);

        RotateToTarget(attackTarget, moveDir);

        UpdateEulerY();

        UpdateSpeed(moveDir,transform.forward);
    }

    private void UpdateSpeed(Vector3 moveDir,Vector3 camForward)
    {
        camForward.y = 0;
        moveDir.y = 0;
        var dot = Vector3.Dot(moveDir, camForward);
        var rate = dot < 0 ? 0.8f : 1f;
        speed = moveSpeed * rate;

        Debug.DrawRay(transform.position, moveDir,Color.red);
        Debug.DrawRay(transform.position, camForward, Color.green);
    }

    private void UpdateEulerY()
    {
        eulerYDelta = transform.eulerAngles.y - lastEulerY;
        lastEulerY = transform.eulerAngles.y;
    }

    public bool IsLockTarget()
    {
        return attackTarget != null;
    }

    private void MoveCharacter(ref Vector3 moveDir, out Vector3 moveDirInCameraSpace)
    {
        var inputDir = InputControl.inputAsset.Player.Movement.ReadValue<Vector2>();
        inputDir.Normalize();

        moveDir.x = inputDir.x;
        moveDir.z = inputDir.y;

        var dirRot = Quaternion.Euler(0, cam.transform.eulerAngles.y, 0);

        moveDirInCameraSpace = moveDir = dirRot * moveDir;

        moveDir.x *= speed;
        moveDir.z *= speed;

        if (InputControl.inputAsset.Player.Jump.triggered)
        {
            moveDir.y = jumpSpeed;
        }

        moveDir.y += gravity * Time.deltaTime;

        cc.Move(moveDir * Time.deltaTime);

        if (cc.isGrounded)
        {
            moveDir.y = 0;
        }
    }

    private void RotateToTarget(Transform target,Vector3 moveDir)
    {
        if (target)
        {
            moveDir = target.position - transform.position;
        }

        moveDir.y = 0;

        if (moveDir.sqrMagnitude == 0)
            return;

        transform.forward = Vector3.RotateTowards(transform.forward,moveDir,rotateSpeed*Mathf.Deg2Rad * Time.deltaTime,0);

    }
    //private void OnDrawGizmos()
    //{
    //    if (cc)
    //        Gizmos.DrawLine(transform.position, cc.velocity * 10);
    //}
}
