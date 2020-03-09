#if !defined(LIGHT_LIB_CGINC)
#define LIGHT_LIB_CGINC

float BandStep(float nl,float step){
	float seg = step / 10;
	return floor(nl * 10 / step) * seg;
}

float StepLight(float nl,float width){
	return smoothstep(0,width,nl)+ 0.33;
}

#endif //LIGHT_LIB_CGINC