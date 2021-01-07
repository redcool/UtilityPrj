Shader "Unlit/ApplyOutlineOffset"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _OutlineWidth ("OutlineWidth", Range(0, 1)) = 1
        _OutlineColor ("OutlineColor", Color) = (1, 1, 1, 1)
        _OffsetTex("_OffsetTex",2d) = "white"{}
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float _OutlineWidth;
            float4 _OutlineColor;
            sampler2D _SelectionBuffer;
            float4 _SelectionBuffer_TexelSize;

            sampler2D _OffsetTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                float4 c1 = tex2D(_MainTex, i.uv);
                float4 c2 = tex2D(_SelectionBuffer, i.uv);
                float2 dirs[8] = {
                    float2(1,0),
                    float2(1,1),
                    float2(0,1),
                    float2(-1,1),
                    float2(-1,0),
                    float2(-1,-1),
                    float2(0,-1),
                    float2(1,-1),
                };
                float4 offsetTex = tex2D(_OffsetTex,i.uv + _Time.x);
                // return offsetTex * c2;

                float buf = 0;
                for(uint id = 0;id<8;id++){
                    buf += (tex2D(_SelectionBuffer, i.uv + dirs[id] * _SelectionBuffer_TexelSize *10* _OutlineWidth));
                }
                buf = saturate(buf) - c2;
                return lerp(c1,offsetTex * _OutlineColor,buf);
            }


            ENDCG
        }
    }
}
