﻿#if UNITY_EDITOR
namespace MyTools
{
    using UnityEngine;
    using System.Collections;
    using UnityEditor;
    using System.IO;
    using System;
    using Object = UnityEngine.Object;
    using System.Collections.Generic;
    using System.Text;
    using MyTools;

    public static class EditorTools
    {
        public static T Save<T>(byte[] bytes, string assetPath)
            where T : Object
        {
            var path = PathTools.GetAssetAbsPath(assetPath);
            File.WriteAllBytes(path, bytes);
            AssetDatabase.Refresh();
            return AssetDatabase.LoadAssetAtPath<T>(assetPath);
        }

        public static void SaveAsset(Object target)
        {
            EditorUtility.SetDirty(target);
            AssetDatabase.SaveAssets();
        }

        #region Selection
        public static T[] GetFilteredFromSelection<T>(SelectionMode mode) where T : Object
        {
#if UNITY_5
            var objs = Selection.GetFiltered(typeof(Object),mode);
            var list = new List<T>(objs.Length);
            foreach (var obj in objs)
            {
                var t = obj as T;
                if (t)
                    list.Add(t);
            }
            return list.ToArray();
#else
            var objs = Selection.GetFiltered(typeof(T), mode);
            return Array.ConvertAll(objs, t => (T)t);
#endif
        }

        public static T GetFirstFilteredFromSelection<T>(SelectionMode mode) where T : Object
        {
            var objs = GetFilteredFromSelection<T>(mode);
            if (objs.Length > 0)
                return objs[0];
            return default(T);
        }
        #endregion
        #region ScriptableObject
        public static T LoadOrCreate<T>(string path) where T : ScriptableObject
        {
            PathTools.CreateAbsFolderPath(path);

            var t = AssetDatabase.LoadAssetAtPath<T>(path);
            if (!t)
            {
                var newT = ScriptableObject.CreateInstance<T>();
                AssetDatabase.CreateAsset(newT, path);
                return AssetDatabase.LoadAssetAtPath<T>(path);
            }
            return t;
        }
        #endregion
        #region Scene
        public static void ForeachSceneObject<T>(Action<T> act) where T : Object
        {
            if (act == null)
                return;

            var objs = Object.FindObjectsOfType<T>();
            foreach (var item in objs)
            {
                act(item);
            }
        }


        #endregion

        #region StaticEditorFlags

        public static bool HasStaticFlag(this GameObject go, StaticEditorFlags flag)
        {
            var flags = GameObjectUtility.GetStaticEditorFlags(go);
            return (flags & flag) == flag;
        }

        public static void RemoveStaticFlags(this GameObject go, StaticEditorFlags flags)
        {
            if (!go)
                return;

            var existFlags = GameObjectUtility.GetStaticEditorFlags(go);
            GameObjectUtility.SetStaticEditorFlags(go, existFlags & ~flags);
        }

        public static void AddStaticFlags(this GameObject go, StaticEditorFlags flags)
        {
            if (!go)
                return;

            var existFlags = GameObjectUtility.GetStaticEditorFlags(go);
            GameObjectUtility.SetStaticEditorFlags(go, existFlags | flags);
        }
        #endregion

    }
}
#endif