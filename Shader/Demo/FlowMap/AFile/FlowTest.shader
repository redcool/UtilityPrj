Shader "Unlit/FlowTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FlowMap("FlowMap",2d) = ""{}
        _Speed("Speed",float) = 1
        _Tiling("Tiling",float) = 1

        _FlowMask("FlowMask",2d) = ""{}
        _FlowThreshold("FlowThreshold",range(0,1)) = 0        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        blend srcAlpha oneMinusSrcAlpha
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
            sampler2D _FlowMap;
            float _Speed,_Tiling;

            sampler2D _FlowMask;
            float _FlowThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float3 Flow1(float2 mainUV,float2 flowVec,float time,bool flowB,float speed){
                float phase = flowB?0.5:0;
                float p = frac(time + phase);
                float2 result = mainUV - flowVec * p * speed;
                float scale = abs((0.5-p)/0.5);
                return float3(result, scale);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float4 flowMap = tex2D(_FlowMap,i.uv);
                float2 flowVec = flowMap.xy * 2 -1;

                float3 flow = Flow1(i.uv,flowVec,_Time.y,true,_Speed);
                float3 flow2 = Flow1(i.uv,flowVec,_Time.y,false,_Speed);

                float4 c = tex2D(_MainTex,flow.xy);
                float4 c2 = tex2D(_MainTex,flow2.xy);
                float4 col = lerp(c,c2,flow.z);
                
                float4 flowMask = tex2D(_FlowMask,i.uv);
                col.a = saturate(flowMask.r - _FlowThreshold);

                //float4 col = ApplyFlowColor(_MainTex,i.uv,flowVec);
                //float4 col = FlowColor(_MainTex,i.uv,flowVec,_Tiling);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
