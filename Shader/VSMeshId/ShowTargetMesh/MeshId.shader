Shader "Unlit/VertexAnim"
{
    Properties
    {
        _MainTex ("Texture", 2dArray) = "white" {}

        _Progress("_Progress",float) = 0
        _Dir("_Dir",vector) = (0,1,0,0)
        _MeshId("_MeshId",range(0,255)) = 0
        _Offset("_Offset",float) = 0
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
                float3 color:COLOR;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 color:TEXCOORD2;
            };

            UNITY_DECLARE_TEX2DARRAY(_MainTex);

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
            UNITY_INSTANCING_BUFFER_END(Props)

            #define _MainTex_ST UNITY_ACCESS_INSTANCED_PROP(Props,_MainTex_ST)

            float _Progress;
            float3 _Dir;
            float _MeshId;

            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float vc = abs(v.color.x * 255 -_MeshId);
                // float colorId = step(vc,0)/255;
                // v.vertex.xyz += _Progress * _Dir * v.color.x;
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = float3(TRANSFORM_TEX(v.uv, _MainTex),_MeshId);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.color = vc;
                o.vertex.w = lerp(o.vertex.w,0,vc);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // return i.color.xyzx;
                float4 col = UNITY_SAMPLE_TEX2DARRAY(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
