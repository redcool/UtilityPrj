using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UtilityLib.Controllers
{
    public class CursorControl : MonoBehaviour
    {
        public bool cursorVisible;
        // Use this for initialization
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {
            if (Input.GetKeyUp(KeyCode.Escape))
            {
                cursorVisible = !cursorVisible;
            }

            //Cursor.lockState = isLockScreen ? CursorLockMode.Locked : CursorLockMode.None;
            Cursor.visible = cursorVisible;
        }
    }
}