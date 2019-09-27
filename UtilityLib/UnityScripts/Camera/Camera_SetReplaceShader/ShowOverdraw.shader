Shader "Unlit/ShowOverdraw"
{
    Properties
    {
        _OverdrawColor ("color", color) = (1,0,0,1)
    }
    SubShader
    {
        Tags {"Queue"="Transparent"}
        LOD 100
		blend one one
		ztest always
		zwrite off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
				float4 vertex:SV_POSITION;
            };

			float4 _OverdrawColor;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return 0.1;
            }
            ENDCG
        }
    }
}
