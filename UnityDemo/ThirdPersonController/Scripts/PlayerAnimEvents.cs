using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public partial class PlayerAnim
{
    public GameObject attackPrefab;
    //GameObject attackVFX;
    /// <summary>
    /// trigger from animation events
    /// </summary>
    public void OnAttack()
    {
        if (!attackPrefab)
            return;

        //if (!attackVFX)
        //{
        //}

        var attackVFX = Instantiate(attackPrefab);
        attackVFX.transform.position = transform.position;
        attackVFX.transform.forward = transform.forward;
        attackVFX.gameObject.SetActive(true);
    }
}
