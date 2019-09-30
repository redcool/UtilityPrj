#if UNITY_EDITOR
namespace AnimationRig
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    [ExecuteAlways]
    public class CreateBoneHierarchy : MonoBehaviour
    {
        //public Transform bonePrefab;
        public int count = 3;
        public float scale = 0.8f;
        public Vector3 position = new Vector3(0,0,-1);

        public bool createHierarchy;
        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {
            if (createHierarchy)
            {
                createHierarchy = false;

                CreateHierarchy();
            }
        }

        void CreateHierarchy()
        {
            var parent = transform;
            for (int i = 0; i < count; i++)
            {
                //var bone = Instantiate(bonePrefab, parent);
                var bone = new GameObject("bone " + i).transform;
                var child = GameObject.CreatePrimitive(PrimitiveType.Cube);
                child.transform.SetParent(bone.transform);

                bone.SetParent(parent);

                bone.localPosition = position;
                bone.localScale = Vector3.one * scale;

                parent = bone;
            }
        }
    }
}
#endif