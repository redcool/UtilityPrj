namespace AnimationRig
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEngine.Animations.Rigging;

    [ExecuteAlways]
    public class CreateDampTransform : MonoBehaviour
    {

        public List<Transform> boneList = new List<Transform>();
        public bool createDampConstraints;
        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {
            if (createDampConstraints)
            {
                createDampConstraints = false;

                CreateDampConstraints();
            }
        }

        void CreateDampConstraints()
        {
            if (boneList.Count < 2)
            {
                Debug.Log("boneList size should be great than 2.");
                return;
            }

            for (int i = 1; i < boneList.Count; i++)
            {
                var dampGo = new GameObject("Damp " + i);
                dampGo.transform.SetParent(transform);

                var dampedTr = dampGo.AddComponent<DampedTransform>();
                dampedTr.data.sourceObject = boneList[i - 1];
                dampedTr.data.constrainedObject = boneList[i];
            }
        }
    }

}