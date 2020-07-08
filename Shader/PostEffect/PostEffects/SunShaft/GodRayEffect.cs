using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class GodRayEffect : MonoBehaviour
{
    public Transform lightpos;
    public Shader curShader;
    public Shader curShaderblend;

    public float Density = 0.01f;
    public float Decay = 0.5f;
    public float Exposure = 0.5f;
    public float Alpha = 1;

    public RenderTexture tempRtA = null;
    public RenderTexture tempRtB = null;

    private Material m_material;
    private Material m_materiaBlend;

    Material material
    {
        get
        {
            if (m_material == null)
            {
                m_material = new Material(curShader);
                m_material.hideFlags = HideFlags.HideAndDontSave;
            }
            return m_material;
        }
    }
    Material materialBlend
    {
        get
        {
            if (m_materiaBlend == null)
            {
                m_materiaBlend = new Material(curShaderblend);
                m_materiaBlend.hideFlags = HideFlags.HideAndDontSave;
            }
            return m_materiaBlend;
        }
    }

    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }

        if (!curShader && !curShader.isSupported)
        {
            enabled = false;
        }
    }
    void OnDisable()
    {
        if (m_material != null)
        {
            DestroyImmediate(m_material);
        }
        if (m_materiaBlend != null)
        {
            DestroyImmediate(m_materiaBlend);
        }
    }

    void CreateBuffers()
    {
        int rt_width = Screen.width; // Screen.width / 4;
        int rt_height = Screen.height; // Screen.height / 4;

        if (!tempRtA)
        {
            tempRtA = new RenderTexture(rt_width, rt_height, 0);
            tempRtA.hideFlags = HideFlags.DontSave;
        }

        if (!tempRtB)
        {
            tempRtB = new RenderTexture(rt_width, rt_height, 0);
            tempRtB.hideFlags = HideFlags.DontSave;
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (curShader != null)
        {
            Vector3 lightScreenPos = Camera.main.WorldToScreenPoint(lightpos.position);

            if (lightScreenPos.z > 0 && lightScreenPos.x > 0 && lightScreenPos.x < GetComponent<Camera>().pixelWidth && lightScreenPos.y > 0 && lightScreenPos.y < GetComponent<Camera>().pixelHeight)
            {
                Vector4 screenLightPos = new Vector4(lightScreenPos.x / GetComponent<Camera>().pixelWidth, lightScreenPos.y / GetComponent<Camera>().pixelHeight, 0, 0);
                material.SetVector("ScreenLightPos", screenLightPos);

                Debug.Log(screenLightPos);

                material.SetFloat("Density", Density);
                material.SetFloat("Decay", Decay);
                material.SetFloat("Exposure", Exposure);
                materialBlend.SetFloat("Alpha", Alpha);

                CreateBuffers();

                Graphics.Blit(sourceTexture, tempRtA, material);
                Graphics.Blit(tempRtA, tempRtB, material);
                Graphics.Blit(tempRtB, tempRtA, material);
                Graphics.Blit(tempRtA, tempRtB, material);
                Graphics.Blit(tempRtB, tempRtA, material);

                materialBlend.SetTexture("_GodRayTex", tempRtA);

                Graphics.Blit(sourceTexture, destTexture, materialBlend, 0);
            }
            else
            {
                Graphics.Blit(sourceTexture, destTexture);
            }
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }
}
