Shader "Hidden/NewImageEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HeightMap("_HeightMap",2d) = ""{}
        _Height("_Height",range(0,1)) = 0

        [Enum(none,0,pm,1,pom,2)]_PMMode("_PMMode",int) = 0
    }

    SubShader
    {
        // No culling or depth

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "ParallaxMapping.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewTS:TEXCOORD1;
                float sampleRatio:COLOR0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                float3 view = ObjSpaceViewDir(v.vertex);

                TANGENT_SPACE_ROTATION(v);
                o.viewTS =  mul(rotation,view);
                o.sampleRatio = 1 - dot(view,v.normal);

                return o;
            }

            sampler2D _MainTex;
            float _Height;
            sampler2D _HeightMap;

            int _PMMode;

            fixed4 frag (v2f i) : SV_Target
            {
                float height = tex2D(_HeightMap,i.uv);

                float2 offset = 0;
                if(_PMMode == 1)
                    offset = ParallaxMapOffset(_Height,i.viewTS,height);
                else if(_PMMode == 2)
                    offset = ParallaxOcclusionOffset(_Height,i.viewTS,i.sampleRatio,i.uv,_HeightMap,4,20);
                
                fixed4 col = tex2D(_MainTex, i.uv + offset);
                // just invert the colors
                return col;
            }
            ENDCG
        }
    }
}
