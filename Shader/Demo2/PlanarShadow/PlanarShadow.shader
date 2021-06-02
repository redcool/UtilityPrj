// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/PlanarShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PlaneHeight("_PlaneHeight",float) = 0
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
                return 0.1;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        Pass
        {
            zwrite off
            ztest always
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

                v2f o;
                o.vertex = UnityWorldToClipPos(float4(worldPos.xyz,0));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return 1;
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
