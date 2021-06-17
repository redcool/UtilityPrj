Shader "Unlit/MeshId_2dArray"
{
    Properties
    {
        _MainTex ("Texture", 2dArray) = "white" {}

        [IntRange]_MeshId("_MeshId",range(0,255)) = 0
        _OffsetX("_Offsetx",float) = 0
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
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 color:COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 color:TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            UNITY_DECLARE_TEX2DARRAY(_MainTex);

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
                UNITY_DEFINE_INSTANCED_PROP(float, _MeshId)
                UNITY_DEFINE_INSTANCED_PROP(float, _OffsetX)
                UNITY_DEFINE_INSTANCED_PROP(Float,_Depth)
            UNITY_INSTANCING_BUFFER_END(Props)

            #define _MainTex_ST UNITY_ACCESS_INSTANCED_PROP(Props,_MainTex_ST)
            #define _OffsetX UNITY_ACCESS_INSTANCED_PROP(Props,_OffsetX)
            #define _MeshId UNITY_ACCESS_INSTANCED_PROP(Props,_MeshId)
            #define _Depth UNITY_ACCESS_INSTANCED_PROP(Props,_Depth)

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float vc = abs(v.color.x * 255 -_MeshId);
                v.vertex.x += _OffsetX;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = float3(TRANSFORM_TEX(v.uv, _MainTex),_Depth);
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
