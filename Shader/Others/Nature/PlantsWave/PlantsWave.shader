Shader "Unlit/PlantsWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		[Header(Wind)]
		[Toggle(EXPAND_BILLBOARD)]_ExpandBillboard("叶片膨胀?",float) = 0
		_Wave("抖动(树枝,边抖动,风向偏移,风向回弹)",vector) = (5,0.2,0.2,0.25)
		_Wind("风力(xyz:方向,w:风强)",vector) = (1,1,1,1)
		_AttenField("无抖动范围 (x: 水平距离,y:竖直距离)",vector) = (1,1,1,1)

		[KeywordEnum(Y,Z)]UP_("向上的轴向",float) = 0
	}
	CGINCLUDE
	// for unity 5
#define UNITY_INSTANCING_BUFFER_START(Props) UNITY_INSTANCING_CBUFFER_START(Props)
#define UNITY_INSTANCING_BUFFER_END(Props) UNITY_INSTANCING_CBUFFER_END
#define ACCESS_INSTANCED_PROP(arr,var) UNITY_ACCESS_INSTANCED_PROP(var)

        #pragma multi_compile_instancing
		#include "UnityCG.cginc"
		#define PLANTS
		#pragma multi_compile UP_Y,UP_Z
		#include "../NatureLib.cginc"

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;

		UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float4, _Wave)			
			UNITY_DEFINE_INSTANCED_PROP(float4, _AttenField)
        UNITY_INSTANCING_BUFFER_END(Props)

		v2f vert(appdata_full v)
		{
			UNITY_SETUP_INSTANCE_ID(v);
			v2f o;
			//UNITY_TRANSFER_INSTANCE_ID(v, o);
			float4 wave = ACCESS_INSTANCED_PROP(Props,_Wave);
			float4 attenField = ACCESS_INSTANCED_PROP(Props,_AttenField);
			v.vertex = ClampVertexWave(v, wave, attenField.y,attenField.x);
			//v.vertex = Squash(v.vertex);	

			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			// sample the texture
			fixed4 col = tex2D(_MainTex, i.uv);
		clip(col.a - 0.2);
			return col;
		}
	ENDCG

    SubShader
    {

        Pass
        {
			Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "lighting.cginc"
			#include "AutoLight.cginc"
            ENDCG
        }


		Pass
		{
			Tags{"lightMode"="ShadowCaster"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
    }

}
