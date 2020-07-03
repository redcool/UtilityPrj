#if !defined(BANK_BRDF_CORE)
#define BANK_BRDF_CORE

struct BankBRDFInfo{
    float3 lightDir;
    float3 lightColor;
    float3 specularColor;
    float3 viewDir;
    float3 worldNormal;
    float ks; //高光系数
    float shininess; //高光指数
};
/**
    bank brdf各项高光项
**/
float3 BankBRDF(BankBRDFInfo b){
    float3 n = normalize(b.worldNormal);
    float3 l = normalize(b.lightDir);
    float3 v = normalize(b.viewDir);
    float3 h = normalize(l + v);
    float3 t = normalize(cross(n,v));

    float nl = saturate(dot(n,l));
    float nv = saturate(dot(n,v));
    float lt = dot(l,t);
    float vt = dot(v,t);
    float bank = pow(sqrt(1 - lt*lt)*sqrt(1 - vt*vt) - lt * vt,b.shininess);
    return  b.ks * bank * b.lightColor * b.specularColor * nl;
}

#endif