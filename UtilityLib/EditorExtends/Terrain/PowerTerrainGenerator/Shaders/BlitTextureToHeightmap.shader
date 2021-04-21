Shader "Hidden/Terrain/BlitTextureToHeightmap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            // sampler2D _MainTex;
            UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex);
            float4 _MainTex_ST;
            float _Height_Scale; // 0.49999
            static const float _HeightOffset = 0.155;
            int _GammaOn;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float4 hm = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_MainTex, i.uv);
                // return GammaToLinearSpaceExact(hm.x);
                // hm.xyz = GammaToLinearSpace(hm.xyz);

                float h = UnpackHeightmap(hm);
                if(_GammaOn)
                    h = GammaToLinearSpaceExact(h);
                    
                h *= _Height_Scale; // 0.155 
                return PackHeightmap(h);
            }
            ENDCG
        }
    }
    Fallback Off
}
