﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/ToonSkin"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Color",color) = (1,1,1,1)

		_RampMap("RampMap",2d) = ""{}
		_RampMap2("RampMap2",2d) = ""{}

        _OutlineThick("Outline Thick",range(0,0.1)) = 0.02
		//_Value("Value(Test)",vector)=(1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
			Cull back
			ztest lequal

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
				LIGHTING_COORDS(1,2)
				float3 viewDir:TEXCOORD3;
				float3 lightDir:TEXCOORD4;
				float3 worldNormal:TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _RampMap;
			sampler2D _RampMap2;
			float4 _Color;

            v2f vert (appdata v)
            {
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = normalize(mul(unity_ObjectToWorld,float4(v.n,0)).xyz);

				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
				o.lightDir = WorldSpaceLightDir(v.vertex);

				TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 v = normalize(i.viewDir);
				float3 l = normalize(i.lightDir);
				float3 n = normalize(i.worldNormal);
				float nl = dot(n, l) * 0.5 + 0.5;
				float nv = dot(n,v);
				float invertNV = clamp((1 - nv),0.05,0.95);
                // sample the texture
                fixed4 mainCol = tex2D(_MainTex, i.uv) * _Color;
				//fresnal
				fixed4 ramp = tex2D(_RampMap, float2(invertNV, 0.25));
				fixed4 fc = lerp(mainCol,ramp * mainCol,ramp.r);
				
				//rim
				fixed4 ramp2 = tex2D(_RampMap2, float2(invertNV * nl, 0));
				fc += ramp2.r * mainCol;
				return fc * nl * _LightColor0;
            }
            ENDCG
        }

        pass{
            cull front
            ztest less
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
			#include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            float _OutlineThick;
            sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata v){
                v2f o = (v2f)o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                float4 n = UnityObjectToClipPos(float4(v.normal,0));
                n *= _OutlineThick * 0.0256;
                n.z += 0.00001;

                o.pos.xyz += n.xyz;
                return o;
            }

            float4 frag(v2f i):SV_Target{
                float4 diffCol = tex2D(_MainTex,i.uv);
                float m = max(max(diffCol.r,diffCol.g),diffCol.b);
                return lerp(diffCol*0.5,diffCol,m) * diffCol;
            }

            ENDCG
        }
    }
}
