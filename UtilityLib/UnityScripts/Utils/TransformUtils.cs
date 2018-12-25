using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace UtilityLib.Utils
{
    public static class TransformUtils
    {
        public static void EvaluateTargetDir(Vector3 targetPos, Vector3 curPos, out float distance, out Vector3 dir)
        {
            targetPos.y = curPos.y;
            var forward = targetPos - curPos;
            distance = forward.magnitude;
            dir = forward.normalized;
        }
    }
}