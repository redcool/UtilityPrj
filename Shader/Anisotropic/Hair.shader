// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Hair"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)

        _NormalMap("NormalMap",2d) = ""{}
        _SpecMaskMap("SpecMaskMap(g:shift,a:Mask)",2d) = ""{}

        _SpecIntensity("SpecIntensity",range(0,1)) = 1

        _SpecColor("SpecColor",color) = (1,1,1,1)
        _SpecPower("SpecPower",float) = 1
        _Shift("Shift",float) = 0

        _SpecColor2("SpecColor2",color) = (1,1,1,1)
        _SpecPower2("SpecPower2",float) = 1
        _Shift2("Shift2",float) = 0
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
                float4 TW0:TEXCOORD1;
                float4 TW1:TEXCOORD2;
                float4 TW2:TEXCOORD3;
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

                float3 t = UnityObjectToWorldDir(v.t.xyz);
                float3 n = UnityObjectToWorldNormal(v.n);
                float3 b = cross(n,t) * v.t.w;
                o.TW0 = float4(t.x,b.x,n.x,worldPos.x);
                o.TW1 = float4(t.y,b.y,n.y,worldPos.y);
                o.TW2 = float4(t.z,b.z,n.z,worldPos.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TW0.w,i.TW1.w,i.TW2.w);
                float3 l = UnityWorldSpaceLightDir(worldPos);
                float3 v = UnityWorldSpaceViewDir(worldPos);

                float3 pn = UnpackNormal(tex2D(_MainTex,i.uv));
                float3 n = normalize(float3(dot(i.TW0.xyz,pn),dot(i.TW1.xyz,pn),dot(i.TW2.xyz,pn)));
                float3 t = normalize(float3(i.TW0.x,i.TW1.x,i.TW2.x));
                float3 b = normalize(float3(i.TW0.y,i.TW1.y,i.TW2.y));

                float4 specMask = tex2D(_SpecMaskMap,i.uv);
                float3 t1 = ShiftTangent(b,n,specMask.r + _Shift);
                float3 t2 = ShiftTangent(b,n,specMask.r + _Shift2);

                float3 spec1 = StrandSpecular(t1,v,l,_SpecPower) * _SpecColor;
                float3 spec2 = StrandSpecular(t2,v,l,_SpecPower2) * _SpecColor2;

                //return float4(spec1+spec2,1);
                float4 col = tex2D(_MainTex,i.uv) * _Color;
                //float diff = lerp(0.8,0.98,dot(n,l));
                col.rgb = col + (spec1 + spec2) *_SpecIntensity;
                col.rgb *= _LightColor0.rgb;
                return col;
            }
            ENDCG
        }
    }
}
