using IronPython.Hosting;
using Microsoft.Scripting.Hosting;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

/// <summary>
/// install UnityPython
/// https://github.com/exodrifter/unity-python/stargazers
/// </summary>
public class PythonComponent : MonoBehaviour
{
    public ScriptEngine engine;
    public ScriptScope scope;
    // Start is called before the first frame update
    void Start()
    {
        var path = Application.dataPath + "/UnityPython/src/test.py";
        var codeStr = File.ReadAllText(path);
        
        if (string.IsNullOrEmpty(codeStr))
            return;

        //scope
        var ad = AppDomain.CreateDomain("ad #2");
        engine = UnityPython.CreateEngine();
        var paths = engine.GetSearchPaths();

        scope = engine.CreateScope();
        var r = engine.Execute(codeStr, scope);

        //invoke
        scope.SetVariable("transform",transform);
        scope.GetVariable("Start")();
    }


    // Update is called once per frame
    void Update()
    {
        if(scope != null)
            scope.GetVariable("Update")();
    }
}
