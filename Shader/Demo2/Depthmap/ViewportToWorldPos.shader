Shader "Unlit/ViewportToWorldPos"
{
    Properties
    {
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos:TEXCOORD2;
            };

            sampler2D _CameraDepthTexture;
            float4x4 unity_MatrixInvVP;

            /**
                
            */
            float4 ClipToViewportPos(float4 clipPos){
                //  clipPos [-w,w]
                float2 uv = clipPos.xy/clipPos.w; // [-1,1]
                uv = uv * 0.5+0.5;//[0,1]
                #if UNITY_REVERSED_Z
                uv.y = 1 - uv.y;
                #endif
                return float4(uv,0,0);
            }

            float4 ViewportToNDCPos(float2 screenPos,float depth){
                float4 clipPos = float4(screenPos * 2-1,depth,1); //[0,1] ->[-1,1]
                #if UNITY_UV_STARTS_AT_TOP
                clipPos.y *= -1;
                #endif
                return clipPos;
            }

            float3 ViewportToWorldPos(float2 screenPos,float depth,float4x4 invVP){
                float4 clipPos = ViewportToNDCPos(screenPos,depth);
                float4 worldPos = mul(invVP,clipPos); // w != 1
                // return worldPos.xyz;
                return worldPos.xyz/worldPos.w;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = o.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = ClipToViewportPos(i.screenPos);
                float depth = tex2D(_CameraDepthTexture, uv);
                // return depth; // non linear
                float3 worldPos = ViewportToWorldPos(uv,depth,unity_MatrixInvVP);
// show worldPos
                uint3 worldPosInt = uint3(abs(worldPos * 10));
                uint3 white = worldPosInt & 1;
                uint white1 = white.x ^ white.y ^ white.z;
                float4 c = white1 ? 1 : 0;
                if(depth > 0.99)
                    return 0;
                if(depth < 0.01)
                    return 0;
                return c;
            }
            ENDCG
        }
    }
}
