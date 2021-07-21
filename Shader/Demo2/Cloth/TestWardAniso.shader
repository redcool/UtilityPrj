// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TestWardAniso" {
   Properties {
      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _AlphaX ("Roughness in Brush Direction", range(0,1)) = 1.0
      _AlphaY ("Roughness orthogonal to Brush Direction", range(0,1)) = 1.0
   }
   SubShader {
      Pass {	
        //  Tags { "LightMode" = "ForwardBase" } 
            // pass for ambient light and first light source
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _AlphaX;
         uniform float _AlphaY;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
               // position of the vertex (and fragment) in world space 
            float3 viewDir : TEXCOORD1;
               // view direction in world space
            float3 normalDir : TEXCOORD2;
               // surface normal vector in world space
            float3 tangentDir : TEXCOORD3;
               // brush direction in world space
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject; 
 
            output.posWorld = mul(modelMatrix, input.vertex);
            output.viewDir = normalize(_WorldSpaceCameraPos 
               - output.posWorld.xyz);
            output.normalDir = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            output.tangentDir = normalize(
               mul(modelMatrix, float4(input.tangent.xyz, 0.0)).xyz);
            output.pos = UnityObjectToClipPos(input.vertex);
            return output;
         }
     
         float D_WardAniso(float nl,float nv,float nh,float th,float bh,float roughT,float roughB){
            float roughTH = th/roughT;
            float roughBH = bh/roughB;
            return sqrt(max(0,nl/nv)) * exp(-2 * (roughTH*roughTH+roughBH*roughBH)/(1+nh));
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float3 lightDirection;
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = 
                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 halfwayVector = 
               normalize(lightDirection + input.viewDir);
            float3 binormalDirection = 
               cross(input.normalDir, input.tangentDir);
            float dotLN = saturate(dot(lightDirection, input.normalDir));
               // compute this dot product only once
 
            float3 ambientLighting = 
               UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
 
            float3 diffuseReflection = 
               attenuation * _LightColor0.rgb * _Color.rgb 
               * dotLN;
 
               float nh = dot(halfwayVector, input.normalDir);
               float nv = dot(input.viewDir, input.normalDir);
               float th = 
                  dot(halfwayVector, input.tangentDir) ;
               float bh = dot(halfwayVector, 
                  binormalDirection);
 
            float3 specularReflection = D_WardAniso(dotLN,nh,nv,th,bh,_AlphaX,_AlphaY)*
                  attenuation * _LightColor0.rgb * _SpecColor.rgb ;

                specularReflection *= dotLN;
            return float4(ambientLighting + diffuseReflection 
               + specularReflection, 1.0);
         }
         ENDCG
      }
 
   }
   Fallback "Specular"
}