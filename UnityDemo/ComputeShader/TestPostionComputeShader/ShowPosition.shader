Shader "Unlit/Position"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #pragma multi_compile_instancing;
            // #pragma instancing_options procedural:Setup
// #pragma editor_sync_compilation

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                uint instanceId:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            StructuredBuffer<float3> _Positions;
            float _Scale;

            v2f vert (appdata v,uint instanceID : SV_InstanceID)
            {
                float3 pos = _Positions[instanceID];
                v.vertex.xyz += pos;
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.instanceId = instanceID;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
