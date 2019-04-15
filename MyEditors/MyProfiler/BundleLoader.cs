using UnityEngine;
using System.Collections;

public class BundleLoader : MonoBehaviour {
    public string url;
    public bool isLoad;
	// Use this for initialization
	void Start () {
	    
	}
	
	// Update is called once per frame
	void Update () {
        if (isLoad)
        {
            isLoad = false;

            StartCoroutine(WaitForLoad(url));
        }
	}

    IEnumerator WaitForLoad(string path)
    {
        var www = new WWW(path);
        yield return www;
        var b = www.assetBundle;
        var names = b.GetAllAssetNames();
        foreach (var item in names)
        {
            Debug.Log(item);
        }
        var s = b.LoadAsset<Shader>("assets/myprofiler/test.shader");
        if (s)
            GetComponent<MeshRenderer>().material.shader = s;
    }
}
