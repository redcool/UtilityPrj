using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class ChangePlayerControl : MonoBehaviour
{
    public Transform attackTarget;
    public CinemachineFreeLook cin;
    public PlayerControlAI[] players;
    public int index;

    [Header("Change interval")]
    public float playerChangeInterval = 2;
    float lastPlayerChangeTime;

    public GameObject respawnEffect;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Keyboard.current.rKey.wasReleasedThisFrame)
        {
            if (! CanChangePlayer())
                return;

            // update next player index
            var lastIndex = index;
            index++;
            index %= players.Length;

            StartCoroutine(WaitForChangePlayer(lastIndex, index));
        }

        if (Keyboard.current.eKey.wasReleasedThisFrame)
        {
            SwitchTarget();
        }
    }

    bool CanChangePlayer()
    {
        // check time
        if (Time.time - lastPlayerChangeTime < playerChangeInterval)
        {
            return false;
        }
        lastPlayerChangeTime = Time.time;
        return true;
    }

    private IEnumerator WaitForChangePlayer(int lastIndex,int index)
    {
        if (respawnEffect)
        {
            PlayEffect(lastIndex);
            yield return new WaitForSeconds(3);
            respawnEffect.SetActive(false);
        }

        Change(lastIndex, index);
    }

    private void PlayEffect(int index)
    {
        var p = players[index];
        respawnEffect.transform.position = p.transform.position + Vector3.up *2;
        respawnEffect.SetActive(true);
    }

    void Change(int lastIndex,int index)
    {
        var player = players[index];
        player.transform.position = players[lastIndex].transform.position;

        cin.Follow = player.transform;
        cin.LookAt = player.transform;

        for (int i = 0; i < players.Length; i++)
        {
            players[i].gameObject.SetActive(i == index);
        }
    }

    void SwitchTarget()
    {
        if (!attackTarget)
            return;
        var p = players[index];
        p.attackTarget = p.attackTarget ? null : attackTarget;
    }
}
