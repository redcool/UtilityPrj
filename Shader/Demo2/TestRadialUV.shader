Shader "Unlit/Test Radial UV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Value("_Value",vector) = (1,0,0,0)
        _Center("_Center",vector) = (0.5,0.5,0,0)
    }
    SubShader
    {
        Pass
        {
            cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            // note: no SV_POSITION in this struct
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 outpos : SV_POSITION ;// clip space position output
            };

            v2f vert (
                float4 vertex : POSITION, // vertex position input
                float2 uv : TEXCOORD0 // texture coordinate input
                )
            {
                v2f o;
                o.uv = uv;
                o.outpos = UnityObjectToClipPos(vertex);
                return o;
            }

            sampler2D _MainTex;
            float4 _Value;
            float4 _Center;

            float2 PolarUV(float2 mainUV,float2 center,float lenScale,float lenOffset,float rotOffset){
                float2 uv = mainUV-center;

                float r = sqrt(uv.x*uv.x+uv.y*uv.y)*lenScale+lenOffset;
                float t = atan2(uv.y,uv.x) + rotOffset;
                return float2(t,r);
            }

            float2 Twirl(float2 uv,float2 center,float scale,float2 offset){
                float2 dir = uv - center;
                float len = length(dir) * scale;

                float2 nuv = float2(
                    dot(float2(cos(len),-sin(len)),dir),
                    dot(float2(sin(len),cos(len)),dir)
                );
                
                return nuv + center + offset;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float2 nuv = PolarUV(i.uv,float2(0.5,0.5),_Value.x,_Value.y,_Value.z);
                // float2 nuv = Twirl(i.uv,_Center.xy,_Center.z,_Value.xy);

                // for pixels that were kept, read the texture and output it
                fixed4 c = tex2D (_MainTex, nuv);
                return c;
            }
            ENDCG
        }
    }
}