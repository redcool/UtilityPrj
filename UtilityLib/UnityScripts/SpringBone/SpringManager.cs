//
//SpingManager.cs for unity-chan!
//
//Original Script is here:
//ricopin / SpingManager.cs
//Rocket Jump : http://rocketjump.skr.jp/unity3d/109/
//https://twitter.com/ricopin416
//
//Revised by N.Kobayashi 2014/06/24
//           Y.Ebata
//
using UnityEngine;
using System.Collections;

namespace UnityChan
{
	public class SpringManager : MonoBehaviour
	{
		//Kobayashi
		// DynamicRatio is paramater for activated level of dynamic animation 
        [Range(0,1)]
		public float dynamicRatio = 1.0f;

		//Ebata
		public float			stiffnessForce;
		public AnimationCurve	stiffnessCurve;
		public float			dragForce;
		public AnimationCurve	dragCurve;
		public SpringBone[] springBones;

        [Space(5f)]
        [Header("根骨")]public GameObject rootBone;
        [Header("根骨硬度")] public float stiffnessRootBone = 0.009f;
        [Header("硬度递减")]public float stiffnessDecrement = 0.001f;

		void Start ()
		{
			UpdateParameters ();
		}

        void Update()
        {
#if UNITY_EDITOR
            //Kobayashi
            if (dynamicRatio >= 1.0f)
                dynamicRatio = 1.0f;
            else if (dynamicRatio <= 0.0f)
                dynamicRatio = 0.0f;
            //Ebata
            UpdateParameters();
#endif
        }
	
		private void LateUpdate ()
		{
			//Kobayashi
			if (dynamicRatio != 0.0f) {
				for (int i = 0; i < springBones.Length; i++) {
					if (dynamicRatio > springBones [i].threshold) {
						springBones [i].UpdateSpring ();
					}
				}
			}
		}

		private void UpdateParameters ()
		{
			UpdateParameter ("stiffnessForce", stiffnessForce, stiffnessCurve);
			UpdateParameter ("dragForce", dragForce, dragCurve);
		}
	
		private void UpdateParameter (string fieldName, float baseValue, AnimationCurve curve)
		{
			var start = curve.keys [0].time;
			var end = curve.keys [curve.length - 1].time;
			//var step	= (end - start) / (springBones.Length - 1);
		
			var prop = springBones [0].GetType ().GetField (fieldName, System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public);
		
			for (int i = 0; i < springBones.Length; i++) {
				//Kobayashi
				if (!springBones [i].isUseEachBoneForceSettings) {
					var scale = curve.Evaluate (start + (end - start) * i / (springBones.Length - 1));
					prop.SetValue (springBones [i], baseValue * scale);
				}
			}
		}

        public void AutoConfig()
        {
            if (!rootBone)
                return;

            var trs = rootBone.GetComponentsInChildren<Transform>();

            for (int i = 0; i < trs.Length-1; i++)
            {
                var curBone = trs[i];

                var sb = curBone.GetComponent<SpringBone>();
                if (!sb)
                    sb = curBone.gameObject.AddComponent<SpringBone>();

                sb.stiffnessForce = stiffnessRootBone - i * stiffnessDecrement;
                sb.child = trs[i + 1];
            }
            springBones = rootBone.GetComponentsInChildren<SpringBone>();
        }
	}
}