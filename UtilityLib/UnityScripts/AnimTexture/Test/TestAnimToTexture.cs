using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace UtilityLib.AnimTexture
{
    public class TestAnimToTexture : MonoBehaviour
    {
        public float time;
        public bool enable;
        public float weight;

        public AnimationClip clip;
        public SkinnedMeshRenderer skin;

        public bool animToTex;

        Animation anim;
        // Start is called before the first frame update
        IEnumerator Start()
        {
            anim = GetComponent<Animation>();

            while (true)
            {
                if (animToTex)
                {
                    animToTex = false;
                    AnimToTextureUtils.BakeMeshToTexture(skin, gameObject, clip);
                }

                yield return 0;
            }
        }


        IEnumerator ClipPlay()
        {
            var state = anim["Attack02 leg"];
            var clip = state.clip;
            var count = (int)(clip.frameRate * clip.length);
            var timePreFrame = 1.0f / count;
            float time = 0;

            for (int i = 0; i < count; i++)
            {
                clip.SampleAnimation(gameObject, time += timePreFrame);
                yield return new WaitForSeconds(.1f);
            }
        }

        IEnumerator AnimationPlay()
        {
            var state = anim["Attack02 leg"];
            var count = (int)(state.length * state.clip.frameRate);
            var timePerFrame = 1.0f / count;
            var time = 0f;
            for (int i = 0; i < count; i++)
            {
                Play(state, time += timePerFrame);
                yield return new WaitForSeconds(.1f);
            }
            Debug.Log("done");
        }

        void Play(AnimationState state, float time)
        {
            state.enabled = true;
            state.time = time;
            state.weight = 1;
            anim.Sample();
            state.enabled = false;
        }
    }
}