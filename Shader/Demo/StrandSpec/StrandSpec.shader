Shader "Unlit/StrandSpec"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("_NormalMap",2d) = "bump"{}
        _NormalScale("_NormalScale",float) = 1

        [Header(Tangent Binormal Mask Map)]
        _TBMaskMap("_TBMaskMap(white:use binormal)",2d) = "white"{}

        [Header(Tangent Shift)]
        _ShiftTex("_ShiftTex(g:shift,b:mask)",2d) = ""{}

        [Header(Spec Shift1)]
        _Shift1("_Shift1",float) = 0
        _SpecPower1("_SpecPower1",range(0.01,1)) = 1
        _SpecColor1("_SpecColor1",color) = (1,1,1,1)
        _SpecIntensity1("_SpecIntensity1",range(0,1)) = 1
        
        [Header(Spec Shift2)]
        // _Shift2On("_Shift2On",int) = 1
        _Shift2("_Shift2",float) = 0
        _SpecPower2("_SpecPower2",range(0.01,1)) = 1
        _SpecColor2("_SpecColor2",color) = (1,1,1,1)
        _SpecIntensity2("_SpecIntensity2",range(0,1)) = 1
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
            #include "UnityStandardUtils.cginc"
            #include "../Lib/TangentLib.cginc"
            #include "StrandSpecLib.cginc"
            #pragma target 3.0

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
                float4 vertex : SV_POSITION;

                // float4 tSpace0:TEXCOORD1;
                // float4 tSpace1:TEXCOORD2;
                // float4 tSpace2:TEXCOORD3;

                TANGENT_SPACE_DECLARE(1,2,3);
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;
            float _NormalScale;

            sampler2D _TBMaskMap;
            sampler2D _ShiftTex;
            float _Shift1,_Shift2;
            float _SpecPower1, _SpecPower2;
            float3 _SpecColor1,_SpecColor2;
            float _SpecIntensity1,_SpecIntensity2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // float3 p = mul(unity_ObjectToWorld,v.vertex);
                // float3 n = normalize(UnityObjectToWorldNormal(v.normal));
                // float3 t = normalize(UnityObjectToWorldDir(v.tangent.xyz));
                // float3 b = normalize(cross(n,t) * v.tangent.w);

                // o.tSpace0 = float4(t.x,b.x,n.x,p.x);
                // o.tSpace1 = float4(t.y,b.y,n.y,p.y);
                // o.tSpace2 = float4(t.z,b.z,n.z,p.z);
                TANGENT_SPACE_COMBINE(v.vertex,v.normal,v.tangent,o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                TANGENT_SPACE_SPLIT(i);

                float3 tn = UnpackScaleNormal(tex2D(_NormalMap,i.uv),_NormalScale);
                float3 n = normalize(float3(
                    dot(i.tSpace0.xyz,tn),
                    dot(i.tSpace1.xyz,tn),
                    dot(i.tSpace2.xyz,tn)
                ));
                normal = n;

                float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 l = normalize(UnityWorldSpaceLightDir(worldPos));

                float4 shiftTex = tex2D(_ShiftTex,i.uv);
                float shift = shiftTex.r;
                float specMask = shiftTex.b;

                // float3 t1 = ShiftTangent(b,n,shift + _Shift1);
                // float3 spec1 = StrandSpecular(t1,v,l,_SpecPower1);

                StrandSpecularData data = (StrandSpecularData)0;
                data.tangent = tangent;
                data.normal = normal;
                data.binormal = binormal;
                data.lightDir = l;
                data.viewDir = v;
                data.shift = shift + _Shift1;
                data.specPower = _SpecPower1 * 128;
                data.tbMask = tex2D(_TBMaskMap,i.uv);
                float spec1 = StrandSpecularColor(data);

                data.specPower = _SpecPower2 * 128;
                data.shift = shift + _Shift2;
                float spec2 = StrandSpecularColor(data);
                float3 specColor = spec1 * _SpecIntensity1 * _SpecColor1 + spec2 * _SpecIntensity2 * _SpecColor2 * specMask;
                // return specColor.xyzx;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb += specColor;
                return col;
            }
            ENDCG
        }
    }
}
