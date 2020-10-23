// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/VPOSDemo"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("_Color",color) = (1,1,1,1)
        _clipIntensity("_clipIntensity",float) = 1
        _FresnalWidthMin("_FresnalWidthMin",range(0,1)) = 0
        _FresnalWidthMax("_FresnalWidthMax",range(0,1)) = 0.1
    }
    SubShader
    {
        // No culling or depth
        // Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma target 3.0

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 n:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 n:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                // float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v,out float4 outpos:SV_POSITION)
            {
                v2f o;
                outpos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.n = UnityObjectToWorldNormal(v.n);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            sampler2D _MainTex;
            float4 _Color;
            float _clipIntensity;
            float _FresnalWidthMin,_FresnalWidthMax;

            fixed4 frag (v2f i,UNITY_VPOS_TYPE screenPos:VPOS) : SV_Target
            {
                // calc fresnal 
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 n = normalize(i.n);
                float nv = saturate(dot(v,n));
                float clipMask = smoothstep(_FresnalWidthMin,_FresnalWidthMax,nv);
                // return clipMask;

                screenPos.xy = floor(screenPos.xy * 0.25) * 0.5;
                float c = frac( (screenPos.x + screenPos.y) * _clipIntensity);
                float c2 = frac(screenPos.x * screenPos.y*0.5);
                clip( -c + clipMask);

                // normal sample
                fixed4 col = tex2D(_MainTex, i.uv)  * c2 * _Color;
                return col;
            }
            ENDCG
        }
    }
}
