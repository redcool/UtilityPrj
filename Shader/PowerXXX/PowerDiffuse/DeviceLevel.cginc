// Upgrade NOTE: replaced 'defined LEVEL_HIGH_PLUS' with 'defined (LEVEL_HIGH_PLUS)'

// Upgrade NOTE: replaced 'defined LEVEL_HIGH_PLUS' with 'defined (LEVEL_HIGH_PLUS)'

#if !defined(DEVICE_LEVEL_CGINC)
#define DEVICE_LEVEL_CGINC

#if defined(LEVEL_MIDDLE) || defined(LEVEL_HIGH) || defined(LEVEL_SUPER)
	#define LEVEL_MIDDLE_PLUS
#endif
#if defined(LEVEL_HIGH) || defined(LEVEL_SUPER)
	#define LEVEL_HIGH_PLUS
#endif

#if defined(RAIN_REFLECTION)
	#define LEVEL_HIGH_PLUS
#endif

#endif // end of DEVICE_LEVEL_CGINC