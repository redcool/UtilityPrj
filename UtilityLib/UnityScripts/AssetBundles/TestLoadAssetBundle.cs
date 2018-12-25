using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Networking;

namespace UtilityLib.AssetBundles
{
    public class TestLoadAssetBundle : MonoBehaviour
    {
        // Start is called before the first frame update
        void Start()
        {
            var buffer = new byte[10];
            StartCoroutine(WaitForLoad());
        }

        /// <summary>
        /// 1 先载入 主Manifest
        /// 2 从主Manifest中获取AssetBundlename
        /// 3 根据 assetbunlePath+assetBundleName,获取对应的assetbundle
        /// 4 从bundle中载入asset,并实例化.
        /// </summary>
        /// <returns></returns>
        IEnumerator WaitForLoad()
        {
            var path = "file:///" + Application.dataPath + "/../ABs/";
            yield return WaitForLoadManifest(path + "ABs", (mani) =>
            {
                foreach (var abName in mani.GetAllAssetBundles())
                {
                    StartCoroutine(WaitForLoadAssetBundle(path + abName, (ab) =>
                    {
                        foreach (var item in ab.GetAllAssetNames())
                        {
                            Debug.Log(item);
                            Instantiate(ab.LoadAsset<GameObject>(item));
                        }
                    }));
                }
            });
        }

        IEnumerator WaitForLoadManifest(string path, Action<AssetBundleManifest> callback)
        {
            yield return WaitForLoadAssetBundle(path, (ab) =>
            {

                var mani = ab.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
                callback?.Invoke(mani);
            });
        }

        IEnumerator WaitForLoadAssetBundle(string path, Action<AssetBundle> callback)
        {
            Debug.Log(path);
            var web = UnityWebRequestAssetBundle.GetAssetBundle(path);
            yield return web.SendWebRequest();
            var ab = DownloadHandlerAssetBundle.GetContent(web);
            callback?.Invoke(ab);
        }
    }
}