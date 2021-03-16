#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 24h ���� editor
/// </summary>
public class DayTimeAnimationMenu
{
    public const string ROOT_PATH = "DayTimeAnimation/";

    [MenuItem(ROOT_PATH + "Add DayTimeAnimationDriver",priority = 2)]
    static void AddDriver()
    {
        var driver = Object.FindObjectOfType<DayTimeAnimationDriver>(true);
        if (!driver)
        {
            var go = new GameObject("DayTimeAnimationDriver");
            driver = go.AddComponent<DayTimeAnimationDriver>();
        }
        EditorGUIUtility.PingObject(driver);
    }

    /// <summary>
    /// �½� item
    /// </summary>
    [MenuItem(ROOT_PATH+ "New DayTimeAnimationItem")]
    static void NewItem()
    {
        var items = Object.FindObjectsOfType<DayTimeAnimationItem>(true);

        var go = new GameObject("DayTimeAnimationDriver_" + items.Length, new[] { typeof(DayTimeAnimationItem) });
        go.transform.SetParent(Selection.activeTransform, false);
    }

    /// <summary>
    /// ���� item���
    /// </summary>
    [MenuItem(ROOT_PATH + "Attach DayTimeAnimationItem To Selection")]
    static void AttachItemComponentToSelection()
    {
        if (!Selection.activeObject)
            return;

        var item = Selection.activeGameObject.GetComponent<DayTimeAnimationItem>();
        if (!item)
            item = Selection.activeGameObject.AddComponent<DayTimeAnimationItem>();
        EditorGUIUtility.PingObject(item);
    }
}
#endif