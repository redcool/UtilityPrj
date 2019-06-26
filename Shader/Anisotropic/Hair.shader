// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Hair"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
	_NormalMap("NormalMap",2d) = ""{}
	_BlendTangent("BlendTangent",float) = 0
		_Gloss("gloss",float) = 1
		_Gloss2("gloss 2",float) = 1

_SpecColor1("spec color1",color) = (1,1,1,1)
_SpecColor2("spec color2",color) = (1,1,1,1)
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

				float3 n:NORMAL;
				float4 t:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

				float4 worldPos:TEXCOORD2;
				float3 n:NORMAL;
				float4 t:TANGENT;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _NormalMap;
			float _BlendTangent;

			float _Gloss;
			float _Gloss2;
			float4 _SpecColor1;
			float4 _SpecColor2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.n = v.n;
				o.t = v.t;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

			float specularFun(float3 t, float3 v, float3 l, float power) {
				float3 h = normalize(l + v);
				float th = dot(t, l);
				float sinTH = sqrt(1 - th * th);
				float atten = smoothstep(-1, 0, th);
				return atten * pow(sinTH,power);
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float3 l = _WorldSpaceLightPos0.xyz;
				float3 v = _WorldSpaceCameraPos.xyz - i.worldPos.xyz;

				float3 t = normalize(i.t);
				float3 n = UnpackNormal(tex2D(_NormalMap,i.uv));//normalize(i.n);
				float3 b = cross(n,t) * i.t.w;
				return (float4)dot(n,t);

				float3x3 tangentRot = float3x3(t,b,n);
				t = lerp(t.xyz, n, _BlendTangent);
				t = normalize(mul(float3(t.xy, 0), tangentRot));

				float4 spec = _SpecColor1 * specularFun(t, v, l, exp2(lerp(1, 11, _Gloss)));
				//spec += _SpecColor2 * specularFun(t, v, l, exp2(lerp(1, 11, _Gloss)));

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col + spec;
            }
            ENDCG
        }
    }
}
