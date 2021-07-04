using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;

[CustomEditor(typeof(SceneFog))]
public class SceneFogEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var inst = target as SceneFog;

        if (GUILayout.Button("UpdateParams"))
        {
            inst.UpdateParams();
        }
    }
}

#endif

public class SceneFog : MonoBehaviour
{
    // public readonly int SCENE_BOUNDS = Shader.PropertyToID("_SceneBounds");

    public Texture sceneFogMap;
    public Texture sceneMainNoiseMap, sceneDetailNoiseMap;
    public Vector4 fogNoiseTilingOffset= new Vector4(1, 1,1,0);
    public Vector3 sceneMin = new Vector3(-200,-10,-200);
    public Vector3 sceneMax = new Vector3(200,10,200);
    public bool sceneHeightFogOn = false;
    public bool sceneFogOn = true;

    public void UpdateParams()
    {
        Shader.SetGlobalTexture("_SceneFogMap",sceneFogMap);
        Shader.SetGlobalTexture("_FogMainNoiseMap", sceneMainNoiseMap);
        Shader.SetGlobalTexture("_FogDetailNoiseMap", sceneDetailNoiseMap);
        // Shader.SetGlobalVector("_SceneBounds", sceneBounds);
        Shader.SetGlobalVector("_SceneMin",sceneMin);
        Shader.SetGlobalVector("_SceneMax",sceneMax);
        Shader.SetGlobalVector("_FogNoiseTilingOffset", fogNoiseTilingOffset);

        Shader.SetGlobalFloat("_SceneFogOn",sceneFogOn?1:0);
        Shader.SetGlobalFloat("_SceneHeightFogOn",sceneHeightFogOn?1:0);
    }
}
