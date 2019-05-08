// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TestShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
					_LightDir("light dir",vector) = (1,1,0,0)
				_ShadowColor("shadow color",color) = (0,0,0,0)
				_ShadowFalloff("falloff",float) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

//阴影pass
Pass
{
	Name "Shadow"

	//用使用模板测试以保证alpha显示正确
	Stencil
	{
		Ref 0
		Comp equal
		Pass incrWrap
		Fail keep
		ZFail keep
	}

	//透明混合模式
	Blend SrcAlpha OneMinusSrcAlpha

	//关闭深度写入
	ZWrite off

	//深度稍微偏移防止阴影与地面穿插
	Offset -1 , 0

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag

	#include "UnityCG.cginc"
	struct appdata
	{
		float4 vertex : POSITION;
	};

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float4 color : COLOR;
	};

	float4 _LightDir;
	float4 _ShadowColor;
	float _ShadowFalloff;


	float3 ProjectToPlane(float4 vertex,float3 lightDir, float planeY) {
		lightDir = normalize(lightDir);

		float3 worldPos = mul(unity_ObjectToWorld,vertex).xyz;

		float3 pos = (float3)0;

		pos.y = min(worldPos.y, planeY);
		pos.xz = worldPos.xz - lightDir.xz * max(0, worldPos.y - planeY) / lightDir.y;
		return pos;
	}

	v2f vert(appdata v)
	{
		v2f o;

		//得到阴影的世界空间坐标
		float3 shadowPos = ProjectToPlane(v.vertex,_LightDir.xyz,_LightDir.w);

		//转换到裁切空间
		o.vertex = UnityWorldToClipPos(shadowPos);

		//得到中心点世界坐标
		float3 center = float3(unity_ObjectToWorld[0].w , _LightDir.w , unity_ObjectToWorld[2].w);
		//计算阴影衰减
		float falloff = 1 - saturate(distance(shadowPos , center) * _ShadowFalloff);

		//阴影颜色
		o.color = _ShadowColor;
		o.color.a *= falloff;

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		return i.color;
	}
	ENDCG
}
    }
}
