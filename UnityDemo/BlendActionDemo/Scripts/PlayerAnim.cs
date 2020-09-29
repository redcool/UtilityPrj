using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public partial class PlayerAnim : MonoBehaviour
{
    public Animator anim;
    public PlayerControlAI ai;

    [Header("Attack Interval")]
    public float attack1Interval = 0.5f;
    public float attack2Interval = 0.5f;

    int ID_SPEED = Animator.StringToHash("Speed");
    int ID_HORIZONTAL = Animator.StringToHash("Horizontal");
    int ID_VERTICAL = Animator.StringToHash("Vertical");
    int ID_IS_LOCK_TARGET = Animator.StringToHash("IsLockTarget");
    int ID_ATTACK = Animator.StringToHash("IsAttack");
    int ID_ATTACK1 = Animator.StringToHash("IsAttack1");
    int ID_ATTACK2 = Animator.StringToHash("IsAttack2");
    int ID_HAS_INPUT = Animator.StringToHash("HasInput");

    public static string STATE_ATTACK = "Attack";
    public static string STATE_ATTACK1 = "Attack1";
    public static string STATE_ATTACK2 = "Attack2";
    public static string STATE_NULL = "NullState";

    Camera cam;
    AnimatorStateInfo attackStateInfo;

    Vector3 moveDir;



    // Start is called before the first frame update
    void Start()
    {
        anim = GetComponent<Animator>();
        ai = GetComponentInParent<PlayerControlAI>();
        cam = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        attackStateInfo = anim.GetCurrentAnimatorStateInfo(1);

        var inputDir = InputControl.inputAsset.Player.Movement.ReadValue<Vector2>();
        var isFire0 = InputControl.inputAsset.Player.Fire0.triggered;

        anim.SetFloat(ID_SPEED, ai.cc.velocity.magnitude + Mathf.Abs(ai.eulerYDelta));
        anim.SetBool(ID_IS_LOCK_TARGET, ai.IsLockTarget());
        anim.SetBool(ID_HAS_INPUT, inputDir.magnitude > 0);

        UpdateMoveDir(inputDir, ref moveDir);

        UpdateMovement(moveDir);

        UpdateAttack(isFire0);
    }

    private void UpdateMoveDir(Vector2 inputDir,ref Vector3 moveDir)
    {
        const float lerpSpeed = 0.08f;
        moveDir.x = Mathf.Lerp(moveDir.x, inputDir.x, lerpSpeed);
        moveDir.z = Mathf.Lerp(moveDir.z, inputDir.y, lerpSpeed);
        //moveDir = Vector3.ClampMagnitude(moveDir, 1);
        //moveDir = new Vector3(inputDir.x, 0, inputDir.y);
    }

    private void UpdateAttack(bool triggered)
    {
        if (!triggered || !attackStateInfo.IsName(STATE_NULL))
            return;

        anim.SetLayerWeight(1, 1);
        anim.SetTrigger(ID_ATTACK);
    }

    private void UpdateMovement(Vector3 moveDir)
    {
        //var moveDir = new Vector3(inputDir.x, 0, inputDir.y);
        moveDir = Quaternion.Euler(0, cam.transform.eulerAngles.y, 0) * Quaternion.Euler(0, -ai.transform.eulerAngles.y, 0) * moveDir;

        
        anim.SetFloat(ID_HORIZONTAL, moveDir.x);
        anim.SetFloat(ID_VERTICAL, moveDir.z);
    }

}
