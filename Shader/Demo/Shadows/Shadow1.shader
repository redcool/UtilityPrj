Shader "Unlit/Shadow1"
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
            NAME "SHADOW1"
            Tags{"LightMode"="ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

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
                float4 vertex : SV_POSITION;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 vert (appdata v) :SV_POSITION
            {
                float4 pos = UnityClipSpaceShadowCasterPos(v.vertex.xyz,v.normal);
                return UnityApplyLinearShadowBias(pos);
            }

            fixed4 frag () : SV_Target
            {
                return 0;
            }
            ENDCG
        }
    }
}
