// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TestReflectProbe"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rough("rough",range(0,1)) = 0
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
            #include "UnityImageBasedLighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD2;
                float3 worldNormal:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Rough;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            //获取ibl的简化代码
            float3 ReflectProbe(UNITY_ARGS_TEXCUBE(tex),half3 refDir,half rough,half4 hdr){
                rough = rough *(1.7-0.7*rough);
                half mip = rough * 6;
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex,refDir,mip);
                return DecodeHDR(rgbm,hdr);
            }
            // UnityImageBasedLighting.cginc
            float3 UnitySpecCube(UNITY_ARGS_TEXCUBE(tex),float3 refDir,float rough,half4 hdr){
                Unity_GlossyEnvironmentData data = (Unity_GlossyEnvironmentData)0;
                data.roughness = rough;
                data.reflUVW = refDir;
                return Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(tex),hdr,data);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 n = normalize(i.worldNormal);
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 r = reflect(-v,n);

                float3 refCol = UnitySpecCube(UNITY_PASS_TEXCUBE(unity_SpecCube0),r,_Rough,unity_SpecCube0_HDR);

                return float4(refCol,1);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
