// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/BankBRDF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ka("ka",float) = 1
        _Kd("kd",float) = 1
        _Ks("Ks",float) = 1
        _Shininess("_Shininess",float) = 1
        _SpecColor("_SpecColor",color) = (1,1,1,1)
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
            #include "Lighting.cginc"
            #include "BankBRDFCore.cginc"

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
            float _Ka,_Kd,_Ks,_Shininess;

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



            fixed4 frag (v2f i) : SV_Target
            {
                float3 n = normalize(i.worldNormal);
                float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 h = normalize(l+v);

                float nl = saturate(dot(n,l));
                float nh = saturate(dot(n,h));

                float3 diffuse = _Kd * _LightColor0.rgb * nl;
                
                BankBRDFInfo b = {l,_LightColor0.rgb,_SpecColor.rgb,v,n,_Ks,_Shininess};
                float3 specular = BankBRDF(b);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = UNITY_LIGHTMODEL_AMBIENT + diffuse * col.rgb + specular;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
