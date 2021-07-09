using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class UIPanelClipParticles : MonoBehaviour {

	private UIPanel panel;
	public ParticleSystemRenderer[] particles;
	public List<Material> materialList = new List<Material>();

	// Use this for initialization
	void Start () {
		panel = GetComponent<UIPanel> ();
		//找到这个粒子系统的Renderer
		particles = GetComponentsInChildren<ParticleSystemRenderer> ();

        foreach (var p in particles)
        {
			materialList.Add(p.sharedMaterial);
        }
	}
    private void OnDestroy()
    {
		materialList.Clear();
    }

    void OnWillRenderObject()
	{
		if (panel.hasClipping)
		{
			//裁剪区域
			Vector4 cr = panel.drawCallClipRange;
			//裁剪边儿的柔和度
			Vector2 soft = panel.clipSoftness;

			Vector2 sharpenss = new Vector2 (1000.0f, 1000.0f);

			if (soft.x > 0f)
				sharpenss.x = cr.z / soft.x;
			if (soft.y > 0f)
				sharpenss.y = cr.w / soft.y;
			
			//经过测试粒子系统产生的Mesh是不受UIPanel缩放比影响的
			//所以要将其缩放比记录下来
			float scale = panel.transform.lossyScale.x;
			//粒子系统的顶点坐标系相对于panel会有一定的偏移，所以要将其position记录下来
			Vector3 position = panel.transform.position;



			var clipRange = new Vector4(
							 -cr.x / cr.z - position.x / scale / cr.z,
							 -cr.y / cr.w - position.y / scale / cr.w,
							 1f / cr.z / scale,
							 1f / cr.w / scale
			);

			var clipArgs = new Vector4(sharpenss.x,sharpenss.y,0,1);
			UpdateParticleMaterial(clipRange, clipArgs);
		}
	}

	void UpdateParticleMaterial(Vector4 clipRagne,Vector4 clipArgs)
    {
        foreach (var m in materialList)
        {
			if (!m)
				continue;

			m.SetVector("_ClipRange0",clipRagne);
			m.SetVector("_ClipArgs0",clipArgs);
        }
    }
}
