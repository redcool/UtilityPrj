Shader "Unlit/Ice"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("_NormalMap",2d) = ""{}
        _MatCap("_MatCap",2d) = ""{}
        _MatCapScale("_MatCapScale",float) = 1

        _MatCapAlpha("_MatCapAlpha",2d) = ""{}

        _EnvMap("_EnvMap",cube) = ""{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "queue"="transparent"}
        LOD 100

        Pass
        {
            blend srcAlpha oneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "../Lib/TangentLib.cginc"

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 viewNormal:TEXCOORD2;
                TANGENT_SPACE_DECLARE(3,4,5);
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;

            sampler2D _MatCap;
            float _MatCapScale;
            sampler2D _MatCapAlpha;
            samplerCUBE _EnvMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                TANGENT_SPACE_COMBINE(v.vertex,v.normal,v.tangent,o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                TANGENT_SPACE_SPLIT(i);

                // normal map
                float3 tn = tex2D(_NormalMap,i.uv);
                float3 n = TangentToWorld(i.tSpace0,i.tSpace1,i.tSpace2,tn);

                // mat cap
                float2 matUV = mul(UNITY_MATRIX_V,n) * 0.5 + 0.5;
                fixed4 mat = tex2D(_MatCap,matUV) ;
                mat.a = tex2D(_MatCapAlpha,matUV);
                mat *= _MatCapScale;
                // return mat;

                // env reflection
                float3 v = UnityWorldSpaceViewDir(worldPos);
                float3 r = reflect(-v,normal);
                float4 envMap = texCUBE(_EnvMap,r);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb += mat;
                col.rgb += envMap*0.1;
                col.a = 0.5;
                return col;
            }
            ENDCG
        }
    }
}
