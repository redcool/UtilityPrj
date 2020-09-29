using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[SharedBetweenAnimators]
public class AttackBehaviour : StateMachineBehaviour
{
    public string triggerId = "IsAttack1";
    public float animTriggerTime = 0.8f;

    // OnStateEnter is called when a transition starts and the state machine starts to evaluate this state
    override public void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        if (!stateInfo.IsName(PlayerAnim.STATE_ATTACK) && !stateInfo.IsName(PlayerAnim.STATE_ATTACK))
            return;

        animator.ResetTrigger(triggerId);
    }

    // OnStateUpdate is called on each Update frame between OnStateEnter and OnStateExit callbacks
    override public void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        if (!stateInfo.IsName(PlayerAnim.STATE_ATTACK) && !stateInfo.IsName(PlayerAnim.STATE_ATTACK1))
            return;

        if (stateInfo.normalizedTime < animTriggerTime)
            return;

        if (InputControl.inputAsset.Player.Fire0.triggered)
            animator.SetTrigger(triggerId);
    }

    // OnStateExit is called when a transition ends and the state machine finishes evaluating this state
    //override public void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    //{

    //}

    // OnStateMove is called right after Animator.OnAnimatorMove()
    //override public void OnStateMove(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    //{
    //    // Implement code that processes and affects root motion
    //}

    // OnStateIK is called right after Animator.OnAnimatorIK()
    //override public void OnStateIK(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    //{
    //    // Implement code that sets up animation IK (inverse kinematics)
    //}
}
