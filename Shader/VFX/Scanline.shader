Shader "Unlit/Scanline"
{
    Properties
    {
        [Header(BlendTex)]
        _MainTex ("Texture", 2D) = "white" {}
        _Color("_Color",color) = (1,1,1,1)
        _MainTex2 ("Texture2", 2D) = "white" {}
        _Color2("_Color2",color) = (1,1,1,1)

        [Header(Mask)]
        _ColorMask("_ColorMask",2d) = "white"{}
        [Toggle]_ColorMaskR("_ColorMaskR",float) = 0

        [Header(ScenLine)]
        _NoiseMap ("_NoiseMap", 2D) = "bump" {}
        _Progress("_Progress",range(0,1)) = 0

        _ScanlineWidth("_ScanlineWidth",vector) = (0,1,0,0)
        _ScanlineColor1("_ScanlineColor1",color) = (1,0,0,0)
        _ScanlineColor2("_ScanlineColor2",color) = (0,1,0,0)

        _BoundY("_BoundY",float) = 5
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
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _MainTex2;
            float4 _Color,_Color2;

            sampler2D _ColorMask;
            float _ColorMaskR;

            float _Progress;
            sampler2D _NoiseMap;
            float4 _ScanlineColor1,_ScanlineColor2;
            float4 _ScanlineWidth;
            float _BoundY;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.uv.z = v.vertex.y/_BoundY;
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 Scanline(float2 width,float uv,float progress,float noise,float4 color1,float4 color2){
                float p = 1 - abs(uv - progress);
                p = smoothstep(width.x, width.y , p) * noise * 5;
                return lerp(color1,color2,p) * p;
            }

            void ApplyLight(float3 n,inout float4 color){
                float nl = dot(n,_WorldSpaceLightPos0.xyz) * 0.5 + 0.5;
                color *= nl;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 noise = tex2D(_NoiseMap,i.uv);
                float progress = lerp(-_ScanlineWidth.x*0.5,1,_Progress);
                float uv = i.uv.z;

                float4 lineColor = Scanline(_ScanlineWidth.xy,uv,progress,noise,_ScanlineColor1,_ScanlineColor2);
                // return lineColor;

                float p2 = smoothstep(0,.1,uv - progress);
                // return p2;
                // sample the texture
                float4 colorMaskTex = tex2D(_ColorMask,i.uv);
                float colorMask = colorMaskTex.a;
                if(_ColorMaskR){
                    colorMask = colorMaskTex.r;
                }

                fixed4 col = tex2D(_MainTex, i.uv) * lerp(1,_Color,colorMask);
                fixed4 col2 = tex2D(_MainTex2, i.uv) * lerp(1,_Color2,colorMask);

                float4 texColor = lerp(col,col2,p2);
                ApplyLight(i.normal,texColor/**/);
                texColor += lineColor;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, texColor);
                return texColor;
            }
            ENDCG
        }
    }
}
