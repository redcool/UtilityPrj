//
//SpringBone.cs for unity-chan!
//
//Original Script is here:
//ricopin / SpringBone.cs
//Rocket Jump : http://rocketjump.skr.jp/unity3d/109/
//https://twitter.com/ricopin416
//
//Revised by N.Kobayashi 2014/06/20
//
using UnityEngine;
using System.Collections;

namespace UnityChan
{
    public class SpringBone : MonoBehaviour
    {
        //次のボーン
        public Transform child;

        //ボーンの向き
        public Vector3 boneAxis = new Vector3(-1.0f, 0.0f, 0.0f);
        public float radius = 0.05f;

        //各SpringBoneに設定されているstiffnessForceとdragForceを使用するか？
        public bool isUseEachBoneForceSettings = true;

        //バネが戻る力
        public float stiffnessForce = 0.01f;

        //力の減衰力
        public float dragForce = 0.4f;
        public Vector3 springForce = new Vector3(0.0f, -0.0001f, 0.0f);
        public SpringCollider[] colliders;
        public bool debug = true;
        //Kobayashi:Thredshold Starting to activate activeRatio
        public float threshold = 0.01f;
        private float springLength;
        private Quaternion localRotation;
        private Transform trs;
        private Vector3 currTipPos;
        private Vector3 prevTipPos;
        //Kobayashi
        private Transform org;
        //Kobayashi:Reference for "SpringManager" component with unitychan 
        private SpringManager managerRef;

		public void Awake()
		{
			trs = transform;
			localRotation = transform.localRotation;
			managerRef = GetComponentInParent<SpringManager>();

            
        }
        public void OnEnable()
        {
			//Kobayashi:Reference for "SpringManager" component with unitychan
			// GameObject.Find("unitychan_dynamic").GetComponent<SpringManager>();
		    

			springLength = Vector3.Distance (trs.position, child.position);
			currTipPos = child.position;
			prevTipPos = child.position;
        }

        /// <summary>
        /// Update by ken.
        /// alteration fps related to time related.
        /// </summary>
        public void UpdateSpring()
        {
            const float FORCE_SCALE = 1000f;
            const float SPEED_SCALE = 10;

            var toPrev = currTipPos - prevTipPos;
            var dt = Time.deltaTime;

            var force = trs.rotation * (boneAxis * stiffnessForce) * FORCE_SCALE;
            force += -toPrev * dragForce * FORCE_SCALE * dt;
            force += springForce * FORCE_SCALE * dt;

            prevTipPos = currTipPos;
            currTipPos += (toPrev + force *0.05f)* SPEED_SCALE * dt;


            currTipPos = trs.position + (currTipPos - trs.position).normalized * springLength;

            currTipPos = CheckColliders(currTipPos);

            var aimDir = trs.TransformDirection(boneAxis);
            var aimRot = Quaternion.FromToRotation(aimDir, currTipPos - trs.position);
            //trs.rotation = aimRot * trs.rotation;
            trs.rotation = Quaternion.Lerp(trs.rotation, aimRot * trs.rotation,managerRef.dynamicRatio);
        }

        Vector3 CheckColliders(Vector3 currTipPos)
        {
            for (int i = 0; i < colliders.Length; i++)
            {
                if (Vector3.Distance(currTipPos, colliders[i].transform.position) <= (radius + colliders[i].radius))
                {
                    Vector3 normal = (currTipPos - colliders[i].transform.position).normalized;
                    currTipPos = colliders[i].transform.position + (normal * (radius + colliders[i].radius));
                    currTipPos = ((currTipPos - trs.position).normalized * springLength) + trs.position;
                }
            }
            return currTipPos;
        }

        private void OnDrawGizmos()
        {
            if (debug)
            {
                Gizmos.color = Color.yellow;
                Gizmos.DrawWireSphere(currTipPos, radius);
            }
        }
    }
}
