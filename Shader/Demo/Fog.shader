// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Fog("Fog",vector) = (1,10,1,2)
        _FogColor("FogColor",color) = (1,1,1,1)
        _CullMode("CullMode",int) = 0
        [Toggle(HEIGHT_FOG)]_HeightFogOn("HeightFog",int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull[_CullMode]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature Z_FOG HEIGHT_FOG

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
                float2 fogRate:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Fog;
            float4 _FogColor;

            float getFogRate(float3 screenPos){
                /**
                // unity 内置参数
                float coord = UNITY_Z_0_FAR_FROM_CLIPSPACE(o.vertex.z);
                o.fogRate.x = (coord) * unity_FogParams.z + unity_FogParams.w;
                */

               // custom
                float coord = max(((1.0-(screenPos.z)/_ProjectionParams.y)*_ProjectionParams.z),0);

                float start = -1/(_Fog.y - _Fog.x);
                float end = _Fog.y /(_Fog.y - _Fog.x);

                return coord * start + end;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                float3 viewPos = UnityObjectToViewPos(v.vertex);
                o.fogRate.y = (_Fog.z - worldPos.y)/(_Fog.w-_Fog.z);
                o.fogRate.x = getFogRate(o.vertex);
 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
// #if defined(UNITY_REVERSED_Z)
// return UNITY_REVERSED_Z;
// #endif

                //return i.fogRate.x;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                float fogRate = i.fogRate.x;
                #if defined(HEIGHT_FOG)
                    fogRate += i.fogRate.y;
                #endif
                fogRate = saturate(fogRate);
                return lerp(_FogColor,col,fogRate);
            }
            ENDCG
        }
    }
}
