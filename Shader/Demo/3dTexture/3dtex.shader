Shader "Unlit/3dtex"
{
    Properties
    {
        _MainTex ("Texture", 3d) = "white" {}
        _StepSize("_StepSize",float) =0.01
        _Offset("_Offset",vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        // cull off

        Pass
        {
            blend srcAlpha oneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPos:TEXCOORD1;
                float3 objectVertex:TEXCOORD2;
            };

            sampler3D _MainTex;
            float4 _MainTex_ST;

            float _StepSize;
            float4 _Offset;

            #define EPSILON 0.00001f

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldPos = worldPos;
                o.objectVertex = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 v = i.worldPos - _WorldSpaceCameraPos;
                float3 rayOrigin = i.objectVertex;
                float3 ray = mul(unity_WorldToObject,float4(normalize(v),1));
// ray = normalize(ray);
                float4 c = 0;
                float3 p = rayOrigin;
                for(int i=0;i<20;i++){
                    // if(max(max(abs(p.x),abs(p.y)),abs(p.z)) <= 0.5 + EPSILON){
                        float4 tex = tex3D(_MainTex,p + _Offset);
                        c += tex * tex.a;
                        c.a *= 0.5;
                        p += ray * _StepSize;
                    // }
                }
                return c;
            }
            ENDCG
        }
    }
}
