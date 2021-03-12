using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[ExecuteAlways]
public class PostParameters : MonoBehaviour
{
    [Serializable]
    public struct DOFParams
    {
        public float start;
        public float end;
    }



    [Header("DOF")]
    public DOFParams dofParams;

    Volume volume;
    
    // Start is called before the first frame update
    void Start()
    {
        volume = GetComponent<Volume>();
    }

    // Update is called once per frame
    void Update()
    {
        if (!volume)
        {
            enabled = false;
            return;
        }

        UpdateDof();
    }

    private void UpdateDof()
    {
        DepthOfField dof;
        if (volume.profile.TryGet(out dof))
        {
            dof.gaussianStart.value = dofParams.start;
            dof.gaussianEnd.value = dofParams.end;
        }
    }
}
