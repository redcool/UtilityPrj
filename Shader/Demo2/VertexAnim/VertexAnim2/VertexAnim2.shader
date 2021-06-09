Shader "Unlit/VertexAnim2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Progress("_Progress",range(0,10)) = 0
        _Dir("_Dir",vector) = (0,1,0,0)
        _AlphaRadius("_AlphaRadius",float) = 3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "queue"="transparent"}
        LOD 100
        blend srcAlpha oneMinusSrcAlpha

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
                float3 color:COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 color:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Progress;
            float3 _Dir;
            float _AlphaRadius;

            v2f vert (appdata v)
            {
                v.vertex.xyz += v.color.x *_Progress *  _Dir;

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.color.xyz = v.color;
                o.color.a = 1- clamp(max(length(v.vertex.xyz)/_AlphaRadius,0.00001),0,1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.w = i.color.w;
                // return col.w;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
