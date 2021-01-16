Shader "Unlit/Receiver2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // required
        Tags {"LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // #pragma multi_compile _ SHADOWS_SCREEN

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                // SHADOW_COORDS(1)
                float4 shadowCoord:TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _ShadowMapTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.shadowCoord = ComputeScreenPos(o.vertex);
                
                // [-1,1] + w => [0,2] * 0.5 => [0,1]
                o.shadowCoord.xy = (float2(o.vertex.x,o.vertex.y * _ProjectionParams.x) + o.vertex.w) * 0.5;
                o.shadowCoord.zw =  o.vertex.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float atten = tex2Dproj(_ShadowMapTexture,i.shadowCoord);
                return col * atten;
            }
            ENDCG
        }
        // required
        UsePass "Unlit/Shadow1/SHADOW1"
    }
}
