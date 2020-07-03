Shader "Custom/BankSurf"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        [Header(BANK)]
        _Ka("ka",float) = 1
        _Kd("kd",float) = 1
        _Ks("Ks",float) = 1
        _Shininess("_Shininess",float) = 1
        _SpecColor("_SpecColor",color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #include "UnityPBSLighting.cginc"
        #include "BankBRDFCore.cginc"
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Bank fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        float _Ka,_Kd,_Ks,_Shininess;


        float4 LightingBank( SurfaceOutputStandard s,float3 viewDir,UnityGI gi) {
            float4 pbr = LightingStandard(s,viewDir,gi);

            float3 l = normalize(_WorldSpaceLightPos0.xyz);
            BankBRDFInfo b = {l,_LightColor0.rgb,_SpecColor.rgb,viewDir,s.Normal,_Ks,_Shininess};
            float3 specular = BankBRDF(b);
            pbr.rgb += specular;
            return pbr;
        }

		void LightingBank_GI(SurfaceOutputStandard s,UnityGIInput data,inout UnityGI gi) {
			LightingStandard_GI(s,data,gi);
		}

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
