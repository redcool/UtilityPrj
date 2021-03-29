#if !defined(POWER_FUR_PASS)
#define POWER_FUR_PASS
    #include "UnityCG.cginc"
    #include "../Lib/NodeLib.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float3 normal:NORMAL;
        float4 color:COLOR;
    };

    struct v2f
    {
        float4 uv : TEXCOORD0;
        UNITY_FOG_COORDS(1)
        float4 vertex : SV_POSITION;
        float3 diffColor:TEXCOORD2;
        float3 specColor:TEXCOORD3;
        float nv:TEXCOORD4;
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;
    float4 _Color;

    sampler2D _FurMaskMap; // r alpha noise, g position offset atten ,b ao
    float4 _FurMaskMap_ST;

    bool _VertexOffsetAttenOn;
    float _Density;
    float _Length,_Rigidness;
    //
    float _FurRadius;
    float _OcclusionPower;
    float4 _OcclusionColor;
    float4 _UVOffset;

    // ao 
    int _FragmentAOOn,_VertexAOOn;

    //flow map
    sampler2D _FlowMap;
    float _FlowMapIntensity;
    int _FlowMapOn;

    //wind
    float _WindSpeed,_WindScale;
    float3 _WindDir;

    // diffuse color
    float4 _Color1,_Color2;

    float _ThicknessMax,_ThicknessMin;

    float3 CalcWind(float3 worldPos){
        float2 uv = worldPos.xz * _Time.y * _WindSpeed;
        float noise = Unity_GradientNoise(uv,_WindScale);
        float3 p = noise * 0.02 * _WindDir;
        return worldPos + p;
    }

    v2f vert (appdata v)
    {
        v2f o = (v2f)0;

        float2 mainUV = TRANSFORM_TEX(v.uv, _MainTex);

        float4 furMask = tex2Dlod(_FurMaskMap,float4(mainUV,0,0)); // r alpha noise, g position offset atten ,b ao

        // vertex offset atten
        float vertexOffsetAtten = 1;
        if(_VertexOffsetAttenOn){
            vertexOffsetAtten = furMask.y;
        }

        // vertex offset
        float3 pos = v.vertex + v.normal * FUR_OFFSET * _Length * vertexOffsetAtten;
        // add gravity
        pos.y += clamp(_Rigidness,-3,3) * pow(FUR_OFFSET,3) * _Length * vertexOffsetAtten;
        
        // apply wind in world space
        float3 worldPos = mul(unity_ObjectToWorld,float4(pos,1));
        worldPos = CalcWind(worldPos);

        o.vertex = mul(UNITY_MATRIX_VP,float4(worldPos,1));
        o.uv.xy = mainUV;

        // uv offset
        float2 uvOffset = FUR_OFFSET * _UVOffset.xy * 0.1;
        o.uv.zw = v.uv * _FurMaskMap_ST.xy + _FurMaskMap_ST.zw + uvOffset;

        UNITY_TRANSFER_FOG(o,o.vertex);

        // diffuse color
        float3 normal = UnityObjectToWorldNormal(v.normal);        
        float3 lightDir = UnityWorldSpaceLightDir(worldPos);
        float3 viewDir = UnityWorldSpaceViewDir(worldPos);
        // float ao = saturate(pow(FUR_OFFSET,_OcclusionPower) * 3);
        float nl = saturate(dot(lightDir,normal));
        float nv = saturate(dot(viewDir,normal));

        // ao = smoothstep(0.1,0.7,FUR_OFFSET);
        // o.diffColor = lerp(_OcclusionColor,1,ao);
        o.diffColor = lerp(_Color1,_Color2,nl);
        if(_VertexAOOn){
            o.diffColor *= furMask.b * (1 - FUR_OFFSET);
        }
        o.nv = pow(nv,1);

        return o;
    }

    float4 frag (v2f i) : SV_Target
    {
        // sample the texture
        float4 col = tex2D(_MainTex, i.uv.xy) * _Color;
        col.xyz *= i.diffColor;

// return col * i.diffColor.xyzx;
        // flow map
        float2 uvOffset = 0;
        if(_FlowMapOn){
            uvOffset = tex2D(_FlowMap,i.uv.xy).xy * 2 - 1;
            uvOffset *= _FlowMapIntensity;
        }
        i.uv.zw += uvOffset * 0.1 * _UVOffset.w * FUR_OFFSET ;

        float4 furMask = tex2D(_FurMaskMap,i.uv.zw); // r alpha noise, g position offset atten ,b ao
        if(_FragmentAOOn){
            col.xyz *= furMask.b;
        }

        float alphaNoise = furMask.x;
        float a = smoothstep(_ThicknessMin,_ThicknessMax,alphaNoise.x * (1 - FUR_OFFSET));
        // a *= i.nv;
        // return i.nv;
// a *= 1 - FUR_OFFSET;
        // float3 c = col.rgb - pow(1 - FUR_OFFSET,3) * .1;
        // a = clamp(a - pow(FUR_OFFSET,2) * _Density,0,1);

        //  --a = saturate(a - pow(FUR_OFFSET,_UVOffset.z) * _Density + FUR_OFFSET * _FurRadius);
        // a = saturate( (a * 2 - (FUR_OFFSET * FUR_OFFSET + FUR_OFFSET*_FurRadius) ));
        // apply fog
        UNITY_APPLY_FOG(i.fogCoord, col);
        return float4(col.xyz,a);
    }
#endif //POWER_FUR_PASS