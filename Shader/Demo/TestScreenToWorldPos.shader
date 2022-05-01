Shader "Unlit/TestScreenToWorldPos"
{
    Properties
    {
    }

    HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

        /**
        screenUV -> ndc -> clip -> view
        [0,1,depth] -> [-1,1,depth] -> [-w,-w,depth] 
        */
        half3 ScreenToWorld(half2 uv,half depth,float4x4 invV,float4x4 invP){
            #if defined(UNITY_UV_STARTS_AT_TOP)
                uv.y = 1-uv.y;
            #endif

            half4 p = half4(uv*2-1,depth,1);
            
            // p = mul(invP,p);
            // p /= p.w;
            // p = mul(invV,p);
            // return p.xyz;

            p = mul(mul(invV,invP),p);
            return p.xyz/p.w;
        }

        half3 ScreenToWorld(half2 uv,half depth,float4x4 invVP){
            #if defined(UNITY_UV_STARTS_AT_TOP)
                uv.y = 1-uv.y;
            #endif

            half4 p = half4(uv*2-1,depth,1);
            p = mul(invVP,p);
            return p.xyz/p.w;
        }
    ENDHLSL
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };


            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                return o;
            }



            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.vertex.xy/_ScreenParams.xy;

                float d = tex2D(_CameraDepthTexture,uv);

                half3 worldPos = ComputeWorldSpacePosition(uv,d,unity_MatrixInvVP);
                worldPos = ScreenToWorld(uv,d,unity_MatrixInvVP);
                worldPos = ScreenToWorld(uv,d,unity_MatrixInvV,unity_MatrixInvP);

                return worldPos.xyzx;
            }
            ENDHLSL
        }
    }
}
