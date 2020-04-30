Shader "Unlit/SimpleCloud"
{
    Properties
    {
        _Layer0("Layer0",2d)=""{}
        _Layer1("Layer1",2d)=""{}
        _Layer2("Layer2",2d)=""{}
        _Layer3("Layer3",2d)=""{}
        _Speed("speed",float) = 1
        _Sharpness("Sharpness",float) = 10
        _Emptiness("Emptiness",float) = 1
        _CloudColor("_CloudColor",color) = (1,1,1,1)
    }
    SubShader
    {
        Tags{"RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100

            blend srcAlpha oneMinusSrcAlpha
        //zwrite Off
        ztest always

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
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 uv1 : TEXCOORD2;
            };

            sampler2D _Layer0;
            sampler2D _Layer1;
            sampler2D _Layer2;
            sampler2D _Layer3;
            float4 _Layer0_ST;
            float4 _Layer1_ST;
            float4 _Layer2_ST;
            float4 _Layer3_ST;
            float _Speed;
            float _Emptiness;
            float _Sharpness;
            float4 _CloudColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _Layer0) + _Time.x * _Speed * float2(1,0);
                o.uv.zw = TRANSFORM_TEX(v.uv, _Layer1) + _Time.x * 1.5 * _Speed * float2(0,1);
                o.uv1.xy = TRANSFORM_TEX(v.uv, _Layer2) + _Time.x * 2 * _Speed * float2(0,-1);
                o.uv1.zw = TRANSFORM_TEX(v.uv, _Layer3) + _Time.x * 3 *_Speed * float2(-1,0);
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 n0 = tex2D(_Layer0,i.uv.xy)/2;
                float4 n1 = tex2D(_Layer0,i.uv.zw)/4;
                float4 n2 = tex2D(_Layer0,i.uv1.xy)/8;
                float4 n3 = tex2D(_Layer0,i.uv1.zw)/16;
                float4 fbm = n0+n1+n2+n3;
                fbm = clamp(fbm,_Emptiness,_Sharpness)/(_Sharpness - _Emptiness);

                float4 ray = float4(0,0.2,0.4,0.6);
                float amount = dot(max(fbm - ray,0),float4(0.25,.25,.25,.25));

                float4 col = 0;
                col.rgb = amount * _CloudColor.rgb + 2*(1-amount) * 0.4;
                col.a = amount * 1.5;
                return col;
            }
            ENDCG
        }
    }
}
