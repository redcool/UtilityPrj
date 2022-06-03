using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Controls;

public class TestTouch : MonoBehaviour
{
    public InputAction touchAction;
    InputMaster inputMaster;
    // Start is called before the first frame update
    void Start()
    {
        inputMaster = new InputMaster();
        inputMaster.Enable();

        touchAction = inputMaster.PlayerControl.Touch0;
        
        //touchAction.Enable();
        touchAction.performed += c => Debug.Log(inputMaster.PlayerControl.Touch0Position.ReadValue<Vector2>());
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
