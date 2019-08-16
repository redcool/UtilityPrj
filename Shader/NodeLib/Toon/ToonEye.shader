// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TestFresnal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)

		_SpecPower("SpecPower",float) = 32
        _SpecColor("SpecColor",color) = (1,1,1,1)

        _ReflectPower("Reflect Power",float) = 32
        _ReflectColor("ReflectColor",color) = (1,1,1,1)

		_F0("F0",float) = 1

        _CubeMap("CubeMap",cube) = ""{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
#include "../NodeLib.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 n:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 n:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

			float _SpecPower;
            //float4 _SpecColor;

            float _ReflectPower;
            float4 _ReflectColor;

			float _F0;

            samplerCUBE _CubeMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.n = v.n;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos.xyz));
				float3 n = normalize(UnityObjectToWorldNormal(i.n));
				float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos.xyz));
				float3 h = normalize(l + v);
				float3 r = reflect(-v,n);

				float nl = dot(n, l) *0.5+0.5;
				float nh = dot(n, h);
				float vr = max(0,dot(r, v));

				float fresnal = SchlickFresnal(v,n, _F0);
                //return fresnal;
				float rr = pow(vr,_ReflectPower);
				float4 refCol =  texCUBE(_CubeMap,r) * rr * _ReflectColor;
                //return refCol;

                float4 specCol = pow(nh, _SpecPower) * nl * _SpecColor * fresnal ;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				return (col + specCol + refCol) * nl * _LightColor0 ;
            }
            ENDCG
        }
    }
}
