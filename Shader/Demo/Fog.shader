// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

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
        _NoiseScale("_NoiseScale",float) = .1
        _Speed("Speed",float) = 10
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

            #pragma shader_feature Z_FOG HEIGHT_FOG

            #include "UnityCG.cginc"
            #include "NodeLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 fogRate:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Fog;
            float4 _FogColor;
            float _NoiseScale;
            float _Speed;

            float getFogRate(float z){
                /**
                // custom
                float coord = max(((1.0-(z)/_ProjectionParams.y)*_ProjectionParams.z),0);

                float start = -1/(_Fog.y - _Fog.x);
                float end = _Fog.y /(_Fog.y - _Fog.x);

                return coord * start + end;
                */

                // unity 内置参数
                float coord = UNITY_Z_0_FAR_FROM_CLIPSPACE(z);
                return (coord) * unity_FogParams.z + unity_FogParams.w;
            }

            float getRandom(float2 uv,float scale){
                return unity_gradientNoise(uv*scale) + 0.5;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                float3 viewPos = UnityObjectToViewPos(v.vertex);
                o.fogRate.y = (_Fog.z - worldPos.y)/(_Fog.w-_Fog.z);

                o.fogRate.x = getFogRate(o.vertex.z);
                
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float fogRate = i.fogRate.x;
                #if defined(HEIGHT_FOG)
                    fogRate += 1-i.fogRate.y;
                #endif

                float2 offset = i.worldPos.xy+i.worldPos.yz + _Time.x * _Speed;
                float rand = getRandom(offset,_NoiseScale);
                fogRate += rand;

                fogRate = saturate(fogRate);
                return lerp(_FogColor,col,fogRate);
            }
            ENDCG
        }
    }
}
