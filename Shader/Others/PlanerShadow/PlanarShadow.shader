// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/PlanarShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(Shadow)]
        _PlaneHeight("_PlaneHeight",float) = 0
        _ShadowColor("_ShadowColor",color) = (0.1,0.1,0.1,0.5)
        _ShadowOffset("_ShadowOffset",float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"Queue"="Opaque"}
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
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float3 normal:TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = mul(unity_ObjectToWorld,v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 l = normalize(_WorldSpaceLightPos0.xyz);
                float3 n = normalize(i.normal);
                float nl = (dot(n,l) * 0.5 + 0.5);

                float atten = lerp(0,1,nl);
                float3 lightColor = _LightColor0 * atten;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.xyz *= lightColor;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags{"Queue"="Transparent"}
            zwrite off
            blend srcAlpha oneMinusSrcAlpha

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

            float _PlaneHeight;
            float4 _ShadowColor;
            float _ShadowOffset;

            float4 PlanarShadowPos(float4 worldPos,float planeHeight,float4 lightDir){
                lightDir = -normalize(lightDir);
                float cosTheta = -lightDir.y;
                float adjLen = worldPos.y - planeHeight;
                float hypotenuse = adjLen/cosTheta;
                worldPos += lightDir * hypotenuse;
                return float4(worldPos.x,planeHeight - lerp(1,0,cosTheta),worldPos.z,1);
            }

            v2f vert (appdata v)
            {
                float4 worldPos = PlanarShadowPos(mul(unity_ObjectToWorld,v.vertex),_PlaneHeight,normalize(_WorldSpaceLightPos0));
                worldPos.z += _ShadowOffset;
                
                v2f o;
                o.vertex = UnityWorldToClipPos(float4(worldPos.xyz,0));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _ShadowColor;
                // // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                // return col;
            }
            ENDCG
        }
    }
}
