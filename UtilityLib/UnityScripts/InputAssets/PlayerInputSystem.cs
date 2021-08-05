using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class PlayerInputSystem
{
    static PlayerInputAsset inputAsset;

    public static PlayerInputAsset.PlayerControlActions InputMaster
    {
        get
        {
            if (inputAsset == null)
            {
                inputAsset = new PlayerInputAsset();
                inputAsset.Enable();
            }
            return inputAsset.PlayerControl;
        }
    }

    public static bool IsFire0Pressed()
    {
        return InputMaster.Fire0.ReadValue<float>() > 0;
    }
}
