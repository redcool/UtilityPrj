﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

namespace MyTools
{
    public static class AnimationTools
    {
        public static AnimationState UseFirstState(this Animation anim)
        {
            foreach (AnimationState state in anim)
            {
                anim.clip = state.clip;
                return state;
            }
            return null;
        }
    }
}
