Shader "Unlit/PlantsWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		//_Wave("Wave()",vector) = (1,1,1,1)
		//_Wind("Wind(xyz,w:whole scale)",vector) = (1,1,1,1)
		_AttenField("AttenField (x: 水平距离,y:竖直距离)",vector) = (1,1,1,1)
	}

    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
#include "../Weather.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Wave;
			float4 _AttenField;

            v2f vert (appdata_full v)
            {
                v2f o;

				//v.vertex = ClampWave_sphere(v,_Wave,2);
				v.vertex = ClampWave(v, _Wave, _AttenField.y,_AttenField.x);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
			clip(col.a - 0.2);
                return col;
            }
            ENDCG
        }
    }
}
