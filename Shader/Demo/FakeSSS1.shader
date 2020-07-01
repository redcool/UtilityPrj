// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/NewSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _LightPos("_LightPos",vector) = (0,1,0,0)

        _OcclusionMap("_OcclusionMap",2d)=""{}
        _Scale("Scale",float) = 1
        _Power("Power",Range(0,1)) = 1
        _AmbientColor("AmbientColor",color)=(1,1,1,1)
        _AmbientScale("AmbientScale",float) = 1
        _Thickmap("Thickmap",2d)=""{}
        _NormalScale("_NormalScale",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        sampler2D _OcclusionMap;
        float _Scale,_Power,_AmbientScale,_NormalScale;
        float4 _AmbientColor;
        sampler2D _Thickmap;
        float3 _LightPos;

        void vert(inout appdata_full v,out Input o){
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.worldPos = mul(unity_ObjectToWorld,v.vertex);
        }

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
            o.Alpha = c.a;
        //     // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Occlusion = tex2D(_OcclusionMap,IN.uv_MainTex);

            float3 l = normalize(_LightPos - IN.worldPos) + o.Normal * _NormalScale;
            float3 v = normalize(UnityWorldSpaceViewDir(IN.worldPos));
            float sss = pow(saturate(dot(-l,v)),128 * _Power) * _Scale;
        
            float thick = tex2D(_Thickmap,IN.uv_MainTex).r;
            //o.Albedo = thick;
            o.Emission = o.Albedo * (sss + _AmbientColor.rgb) * _AmbientScale * thick;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
