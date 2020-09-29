using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputControl : MonoBehaviour
{
    public static InputAsset inputAsset;

    private void Awake()
    {
        SetupCinemachineInput();

        inputAsset = new InputAsset();
        inputAsset.Enable();
    }

    public static void SetupCinemachineInput()
    {
        CinemachineCore.GetInputAxis = (axisName) =>
        {
            var dir = InputControl.inputAsset.Player.Look.ReadValue<Vector2>();
            if (axisName == "Mouse X")
                return dir.x;
            else if (axisName == "Mouse Y")
                return dir.y;
            return 0;
        };
    }
}
