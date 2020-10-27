using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class CreatePlayerMenu
{
    public const string ROOT_MENU = "Game/Player";

    [MenuItem(ROOT_MENU+"/Create")]
    static void CreatePlayer()
    {
        var curGo = Selection.activeGameObject;
        if (!curGo)
            return;

        var rootGo = new GameObject("Player");
        curGo.transform.SetParent(rootGo.transform, false);

        rootGo.AddComponent<PlayerControlAI>();
        curGo.AddComponent<PlayerAnim>();

        var cc = rootGo.AddComponent<CharacterController>();
        cc.center = new Vector3(0,1.1f,0);

        var camTarget = new GameObject("Camera Target");
        camTarget.transform.SetParent(rootGo.transform,false);
        camTarget.transform.localPosition = new Vector3(0,1.2f,0);
    }
}
