Shader "Tutorial/046_Partial_Derivatives/fire1"{
	//show values to edit in inspector
	Properties{
	    _MainTex ("Fire Noise", 2D) = "white" {}
	    _ScrollSpeed("Animation Speed", Range(0, 2)) = 1
	
		_Color1 ("Color 1", Color) = (0, 0, 0, 1)
		_Color2 ("Color 2", Color) = (0, 0, 0, 1)
		_Color3 ("Color 3", Color) = (0, 0, 0, 1)
		
		_Edge1 ("Edge 1-2", Range(0, 1)) = 0.25
		_Edge2 ("Edge 2-3", Range(0, 1)) = 0.5
	}

	SubShader{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType"="transparent" "Queue"="transparent"}
		
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off

		Pass{
			CGPROGRAM

			//include useful shader functions
			#include "UnityCG.cginc"

			//define vertex and fragment shader
			#pragma vertex vert
			#pragma fragment frag

			//tint of the texture
			fixed4 _Color1;
			fixed4 _Color2;
			fixed4 _Color3;
			
			float _Edge1;
			float _Edge2;
			
			float _ScrollSpeed;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;

			//the object data that's put into the vertex shader
			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			//the data that's used to generate fragments and can be read by the fragment shader
			struct v2f{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//the vertex shader
			v2f vert(appdata v){
				v2f o;
				//convert the vertex positions from object space to clip space so they can be rendered
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			

			float Gradient(float noise,float2 uv){
				float g = uv.y;
			    float delta = fwidth(uv.y);
				// return saturate(g = noise);
				return saturate((g - noise)/delta*2);
			}
			float4 Gradient3(float fireNoise,float2 vertexUV){
				float uv = (1-vertexUV.y) * (1-vertexUV.y);
				float a = Gradient(fireNoise,uv);
				float b = Gradient(fireNoise,uv - _Edge1);
				float c = Gradient(fireNoise,uv - _Edge2);
				return lerp(lerp(_Color1* a,_Color2,b),_Color3,c);
			}

			//the fragment shader
			fixed4 frag(v2f i) : SV_TARGET{

			    //calculate fire UVs and animate them
			    float2 fireUV = TRANSFORM_TEX(i.uv, _MainTex);
			    fireUV.y -= _Time.y * _ScrollSpeed;
			    //get the noise texture
			    float fireNoise = tex2D(_MainTex, fireUV).x;

				return Gradient3(fireNoise,i.uv);

			}

			ENDCG
		}
	}
}