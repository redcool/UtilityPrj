using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public static class InputControl
{
    public static InputAsset inputAsset = new InputAsset();

    static InputControl()
    {
        inputAsset.Enable();

        CinemachineCore.GetInputAxis = (axisName) =>
        {
            var dir = inputAsset.Player.Movement.ReadValue<Vector2>();
            if (axisName == "Mouse X")
                return dir.x;
            else if (axisName == "Mouse Y")
                return dir.y;
            return 0;
        };
    }
}
