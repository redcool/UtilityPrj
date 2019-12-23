// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Hair"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)

        _NormalMap("NormalMap",2d) = ""{}
        _SpecMaskMap("SpecMaskMap(r:shift)",2d) = ""{}

        _TangentRate("TangentRate",range(0,1)) = 0

        _SpecIntensity("SpecIntensity",range(0,1)) = 1

        _SpecColor("SpecColor",color) = (1,1,1,1)
        _SpecPower("SpecPower",float) = 1
        _Shift("Shift",float) = 0

        _SpecColor2("SpecColor2",color) = (1,1,1,1)
        _SpecPower2("SpecPower2",float) = 1
        _Shift2("Shift2",float) = 0

        _Saturate("Saturate",range(0.5,3)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            //#include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "../Include/NodeLib.cginc"
            #include "../Include/TangentLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 t:TANGENT;
                float3 n:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                V2F_TANGENT_TO_WORLD(1,2,3);
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            sampler2D _NormalMap;
            sampler2D _SpecMaskMap;
            //float4 _SpecColor;
            float4 _SpecColor2;

            float _SpecPower;
            float _SpecPower2;
            float _SpecIntensity;

            sampler2D _SpecShiftMap;
            float _Shift;
            float _Shift2;

            float _Saturate;
            float _TangentRate;

            float3 ShiftTangent(float3 t,float3 n,float shift){
                return normalize(t + n * shift);
            }

            float StrandSpecular(float3 t,float3 v,float3 l,float exponent){
                float3 h = normalize(l+v);
                float th = dot(t,h);
                float sinTH = sqrt(1.0 - th * th);
                float dirAtten = smoothstep(-1,0,th);
                return dirAtten * pow(sinTH,exponent);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float4 worldPos = mul(unity_ObjectToWorld,v.vertex);

                TangentToWorldVertex(v.vertex,v.n,v.t,o.t2w0,o.t2w1,o.t2w2);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 pn = UnpackNormal(tex2D(_NormalMap,i.uv));
                
                float3 worldPos,t,b,n;
                TangentToWorldFrag(pn,i.t2w0,i.t2w1,i.t2w2,worldPos,t,b,n);

                float3 l = UnityWorldSpaceLightDir(worldPos);
                float3 v = UnityWorldSpaceViewDir(worldPos);

                float4 specMask = tex2D(_SpecMaskMap,i.uv);

                float tan = lerp(t,b,_TangentRate);
                float3 t1 = ShiftTangent(tan,n,specMask.r + _Shift);
                float3 t2 = ShiftTangent(tan,n,specMask.r + _Shift2);

                float3 spec1 = StrandSpecular(t1,v,l,_SpecPower) * _SpecColor;
                float3 spec2 = StrandSpecular(t2,v,l,_SpecPower2) * _SpecColor2;

                float nl = dot(n,l) * 0.5+0.5;
                //return float4(spec1+spec2,1);
                float4 col = tex2D(_MainTex,i.uv) * _Color;
                
                float3 diff = lerp(col,col*nl,nl);
                float g = Gray(diff);
                diff = lerp((float3)g,diff,_Saturate);

                col.rgb = diff + (spec1 + spec2) * nl *_SpecIntensity;
                col.rgb *= _LightColor0.rgb;
                return col;
            }
            ENDCG
        }
    }
}
