using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CinemachinInput : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {

        CinemachineCore.GetInputAxis = (axisName) =>
        {
            var dir = InputControl.inputAsset.Player.Movement.ReadValue<Vector2>();
            if (axisName == "Mouse X")
                return dir.x;
            else if (axisName == "Mouse Y")
                return dir.y;
            return 0;
        };
    }

}
