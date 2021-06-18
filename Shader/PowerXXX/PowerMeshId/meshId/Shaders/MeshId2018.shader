Shader "Unlit/MeshId2018"
{
    Properties
    {
        _MainTex ("Texture", 2d) = "white" {}

        _MeshId("_MeshId",range(0,255)) = 0
        _OffsetX("_Offsetx",float) = 0

        [Toggle]_TexArrOn("_TexArrOn",float) = 0
        _TexArr("_TexArr",2darray)=""{}
        [IntRange]_Depth("_Depth",range(0,255)) = 0
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
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 color:TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            UNITY_DECLARE_TEX2DARRAY(_TexArr);

            UNITY_INSTANCING_BUFFER_START(Props2018)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
                UNITY_DEFINE_INSTANCED_PROP(float, _MeshId)
                UNITY_DEFINE_INSTANCED_PROP(float, _OffsetX)
                UNITY_DEFINE_INSTANCED_PROP(float, _TexArrOn)
                UNITY_DEFINE_INSTANCED_PROP(float4, _TexArr_ST)
                UNITY_DEFINE_INSTANCED_PROP(float,_Depth)
            UNITY_INSTANCING_BUFFER_END(Props2018)

            // in 2018 ,same macro name not support, so plus prefix _
            #define __MainTex_ST UNITY_ACCESS_INSTANCED_PROP(Props2018,_MainTex_ST)
            #define __OffsetX UNITY_ACCESS_INSTANCED_PROP(Props2018,_OffsetX)
            #define __MeshId UNITY_ACCESS_INSTANCED_PROP(Props2018,_MeshId)
            #define __TexArrOn UNITY_ACCESS_INSTANCED_PROP(Props2018,_TexArrOn)
            #define __TexArr_ST UNITY_ACCESS_INSTANCED_PROP(Props2018,_TexArr_ST)
            #define __Depth UNITY_ACCESS_INSTANCED_PROP(Props2018,_Depth)

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float vc = abs((v.color.x * 255) -__MeshId);
                v.vertex.x += __OffsetX;
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                if(__TexArrOn){
                    o.uv.xyz = float3(v.uv *__TexArr_ST.xy +__TexArr_ST.zw ,__Depth);
                }else{
                    o.uv.xy = v.uv * __MainTex_ST.xy + __MainTex_ST.zw;
                }
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.color = vc;
                o.vertex.w = lerp(o.vertex.w,-1,vc);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                // return i.color.xyzx;
                float4 col = 0;
                if(__TexArrOn){
                    col = UNITY_SAMPLE_TEX2DARRAY(_TexArr, i.uv.xyz);
                }else{
                    col = tex2D(_MainTex, i.uv.xy);
                }
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
