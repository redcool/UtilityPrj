using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BetterJump : MonoBehaviour
{
    [Header("Jump")]
    [Range(1,10)]public float jumpVelocity=5;
    Rigidbody2D rigid2d;

    [Header("Jump adjust")]
    public bool enableBetterJump = true;
    public float fallScale = 1.5f;
    public float lowJumpScale = 1;
    // Start is called before the first frame update
    void Start()
    {
        rigid2d = GetComponent<Rigidbody2D>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Jump"))
        {
            rigid2d.velocity = Vector2.up * jumpVelocity;
        }

        if (enableBetterJump)
            CheckJumpBetter();
    }

    void CheckJumpBetter()
    {
        if (rigid2d.velocity.y < 0)
        {
            rigid2d.velocity += Vector2.up * Physics2D.gravity.y * fallScale * Time.deltaTime;
        }
        else if (rigid2d.velocity.y > 0 && !Input.GetButton("Jump"))
        {
            rigid2d.velocity += Vector2.up * Physics2D.gravity.y * lowJumpScale * Time.deltaTime;
        }
    }
}
