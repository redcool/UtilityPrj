// Compiled shader for Current graphics device, uncompressed size: 14.6KB

// Skipping shader variants that would not be included into build of current scene.

Shader "Unlit/Test1" {
	Properties{
	 _MainTex("Texture", 2D) = "white" { }
	}
		SubShader{
		 LOD 100
		 Tags { "RenderType" = "Opaque" }


		// Stats for Vertex shader:
		//       d3d11 : 5 math
		//    d3d11_9x : 5 math
		// Stats for Fragment shader:
		//       d3d11 : 0 math, 1 texture
		//    d3d11_9x : 0 math, 1 texture
		Pass {
		 Tags { "RenderType" = "Opaque" }
		 GpuProgramID 12253
	   Program "vp" {
	   SubProgram "d3d11 " {
		   // Stats: 5 math
		   Bind "vertex" Vertex
		   Bind "texcoord" TexCoord0
		   ConstBuffer "$Globals" 112
		   Vector 96[_MainTex_ST]
		   ConstBuffer "UnityPerDraw" 352
		   Matrix 0[glstate_matrix_mvp]
		   BindCB  "$Globals" 0
		   BindCB  "UnityPerDraw" 1
		   "vs_4_0
		   root12:aaacaaaa
		   eefiecedliinmgehhpmkmolmmdbhgocpfdmidlmjabaaaaaaamacaaaaadaaaaaa
		   cmaaaaaaiaaaaaaaniaaaaaaejfdeheoemaaaaaaacaaaaaaaiaaaaaadiaaaaaa
		   aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
		   adaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfceeaaklkl
		   epfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
		   aaaaaaaaadamaaaaebaaaaaaaaaaaaaaabaaaaaaadaaaaaaabaaaaaaapaaaaaa
		   feeffiedepepfceeaafdfgfpfaepfdejfeejepeoaaklklklfdeieefccmabaaaa
		   eaaaabaaelaaaaaafjaaaaaeegiocaaaaaaaaaaaahaaaaaafjaaaaaeegiocaaa
		   abaaaaaaaeaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaabaaaaaa
		   gfaaaaaddccabaaaaaaaaaaaghaaaaaepccabaaaabaaaaaaabaaaaaagiaaaaac
		   abaaaaaadcaaaaaldccabaaaaaaaaaaaegbabaaaabaaaaaaegiacaaaaaaaaaaa
		   agaaaaaaogikcaaaaaaaaaaaagaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaa
		   aaaaaaaaegiocaaaabaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
		   abaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
		   aaaaaaaaegiocaaaabaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaa
		   dcaaaaakpccabaaaabaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaaaaaaaaaa
		   egaobaaaaaaaaaaadoaaaaab"
		   }
		   SubProgram "d3d11_9x " {
			   // Stats: 5 math
			   Bind "vertex" Vertex
			   Bind "texcoord" TexCoord0
			   ConstBuffer "$Globals" 112
			   Vector 96[_MainTex_ST]
			   ConstBuffer "UnityPerDraw" 352
			   Matrix 0[glstate_matrix_mvp]
			   BindCB  "$Globals" 0
			   BindCB  "UnityPerDraw" 1
			   "vs_4_0_level_9_1
			   root12:aaacaaaa
			   eefiecedhdmejomlfakcjnjcbihghiejcnphjhejabaaaaaapiacaaaaaeaaaaaa
			   daaaaaaabiabaaaaemacaaaakaacaaaaebgpgodjoaaaaaaaoaaaaaaaaaacpopp
			   kaaaaaaaeaaaaaaaacaaceaaaaaadmaaaaaadmaaaaaaceaaabaadmaaaaaaagaa
			   abaaabaaaaaaaaaaabaaaaaaaeaaacaaaaaaaaaaaaaaaaaaaaacpoppbpaaaaac
			   afaaaaiaaaaaapjabpaaaaacafaaabiaabaaapjaaeaaaaaeaaaaadoaabaaoeja
			   abaaoekaabaaookaafaaaaadaaaaapiaaaaaffjaadaaoekaaeaaaaaeaaaaapia
			   acaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaaeaaoekaaaaakkjaaaaaoeia
			   aeaaaaaeaaaaapiaafaaoekaaaaappjaaaaaoeiaaeaaaaaeaaaaadmaaaaappia
			   aaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiappppaaaafdeieefccmabaaaa
			   eaaaabaaelaaaaaafjaaaaaeegiocaaaaaaaaaaaahaaaaaafjaaaaaeegiocaaa
			   abaaaaaaaeaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaabaaaaaa
			   gfaaaaaddccabaaaaaaaaaaaghaaaaaepccabaaaabaaaaaaabaaaaaagiaaaaac
			   abaaaaaadcaaaaaldccabaaaaaaaaaaaegbabaaaabaaaaaaegiacaaaaaaaaaaa
			   agaaaaaaogikcaaaaaaaaaaaagaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaa
			   aaaaaaaaegiocaaaabaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
			   abaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
			   aaaaaaaaegiocaaaabaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaa
			   dcaaaaakpccabaaaabaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaaaaaaaaaa
			   egaobaaaaaaaaaaadoaaaaabejfdeheoemaaaaaaacaaaaaaaiaaaaaadiaaaaaa
			   aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
			   adaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfceeaaklkl
			   epfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
			   aaaaaaaaadamaaaaebaaaaaaaaaaaaaaabaaaaaaadaaaaaaabaaaaaaapaaaaaa
			   feeffiedepepfceeaafdfgfpfaepfdejfeejepeoaaklklkl"
			   }
			   SubProgram "d3d11 " {
				   // Stats: 5 math
				   Keywords { "A" }
				   Bind "vertex" Vertex
				   Bind "texcoord" TexCoord0
				   ConstBuffer "$Globals" 112
				   Vector 96[_MainTex_ST]
				   ConstBuffer "UnityPerDraw" 352
				   Matrix 0[glstate_matrix_mvp]
				   BindCB  "$Globals" 0
				   BindCB  "UnityPerDraw" 1
				   "vs_4_0
				   root12:aaacaaaa
				   eefiecedliinmgehhpmkmolmmdbhgocpfdmidlmjabaaaaaaamacaaaaadaaaaaa
				   cmaaaaaaiaaaaaaaniaaaaaaejfdeheoemaaaaaaacaaaaaaaiaaaaaadiaaaaaa
				   aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
				   adaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfceeaaklkl
				   epfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
				   aaaaaaaaadamaaaaebaaaaaaaaaaaaaaabaaaaaaadaaaaaaabaaaaaaapaaaaaa
				   feeffiedepepfceeaafdfgfpfaepfdejfeejepeoaaklklklfdeieefccmabaaaa
				   eaaaabaaelaaaaaafjaaaaaeegiocaaaaaaaaaaaahaaaaaafjaaaaaeegiocaaa
				   abaaaaaaaeaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaabaaaaaa
				   gfaaaaaddccabaaaaaaaaaaaghaaaaaepccabaaaabaaaaaaabaaaaaagiaaaaac
				   abaaaaaadcaaaaaldccabaaaaaaaaaaaegbabaaaabaaaaaaegiacaaaaaaaaaaa
				   agaaaaaaogikcaaaaaaaaaaaagaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaa
				   aaaaaaaaegiocaaaabaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
				   abaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
				   aaaaaaaaegiocaaaabaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaa
				   dcaaaaakpccabaaaabaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaaaaaaaaaa
				   egaobaaaaaaaaaaadoaaaaab"
				   }
				   SubProgram "d3d11_9x " {
					   // Stats: 5 math
					   Keywords { "A" }
					   Bind "vertex" Vertex
					   Bind "texcoord" TexCoord0
					   ConstBuffer "$Globals" 112
					   Vector 96[_MainTex_ST]
					   ConstBuffer "UnityPerDraw" 352
					   Matrix 0[glstate_matrix_mvp]
					   BindCB  "$Globals" 0
					   BindCB  "UnityPerDraw" 1
					   "vs_4_0_level_9_1
					   root12:aaacaaaa
					   eefiecedhdmejomlfakcjnjcbihghiejcnphjhejabaaaaaapiacaaaaaeaaaaaa
					   daaaaaaabiabaaaaemacaaaakaacaaaaebgpgodjoaaaaaaaoaaaaaaaaaacpopp
					   kaaaaaaaeaaaaaaaacaaceaaaaaadmaaaaaadmaaaaaaceaaabaadmaaaaaaagaa
					   abaaabaaaaaaaaaaabaaaaaaaeaaacaaaaaaaaaaaaaaaaaaaaacpoppbpaaaaac
					   afaaaaiaaaaaapjabpaaaaacafaaabiaabaaapjaaeaaaaaeaaaaadoaabaaoeja
					   abaaoekaabaaookaafaaaaadaaaaapiaaaaaffjaadaaoekaaeaaaaaeaaaaapia
					   acaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaaeaaoekaaaaakkjaaaaaoeia
					   aeaaaaaeaaaaapiaafaaoekaaaaappjaaaaaoeiaaeaaaaaeaaaaadmaaaaappia
					   aaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiappppaaaafdeieefccmabaaaa
					   eaaaabaaelaaaaaafjaaaaaeegiocaaaaaaaaaaaahaaaaaafjaaaaaeegiocaaa
					   abaaaaaaaeaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaabaaaaaa
					   gfaaaaaddccabaaaaaaaaaaaghaaaaaepccabaaaabaaaaaaabaaaaaagiaaaaac
					   abaaaaaadcaaaaaldccabaaaaaaaaaaaegbabaaaabaaaaaaegiacaaaaaaaaaaa
					   agaaaaaaogikcaaaaaaaaaaaagaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaa
					   aaaaaaaaegiocaaaabaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
					   abaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
					   aaaaaaaaegiocaaaabaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaa
					   dcaaaaakpccabaaaabaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaaaaaaaaaa
					   egaobaaaaaaaaaaadoaaaaabejfdeheoemaaaaaaacaaaaaaaiaaaaaadiaaaaaa
					   aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
					   adaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfceeaaklkl
					   epfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
					   aaaaaaaaadamaaaaebaaaaaaaaaaaaaaabaaaaaaadaaaaaaabaaaaaaapaaaaaa
					   feeffiedepepfceeaafdfgfpfaepfdejfeejepeoaaklklkl"
					   }
					   SubProgram "d3d11 " {
						   // Stats: 5 math
						   Keywords { "B" }
						   Bind "vertex" Vertex
						   Bind "texcoord" TexCoord0
						   ConstBuffer "$Globals" 112
						   Vector 96[_MainTex_ST]
						   ConstBuffer "UnityPerDraw" 352
						   Matrix 0[glstate_matrix_mvp]
						   BindCB  "$Globals" 0
						   BindCB  "UnityPerDraw" 1
						   "vs_4_0
						   root12:aaacaaaa
						   eefiecedliinmgehhpmkmolmmdbhgocpfdmidlmjabaaaaaaamacaaaaadaaaaaa
						   cmaaaaaaiaaaaaaaniaaaaaaejfdeheoemaaaaaaacaaaaaaaiaaaaaadiaaaaaa
						   aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
						   adaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfceeaaklkl
						   epfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
						   aaaaaaaaadamaaaaebaaaaaaaaaaaaaaabaaaaaaadaaaaaaabaaaaaaapaaaaaa
						   feeffiedepepfceeaafdfgfpfaepfdejfeejepeoaaklklklfdeieefccmabaaaa
						   eaaaabaaelaaaaaafjaaaaaeegiocaaaaaaaaaaaahaaaaaafjaaaaaeegiocaaa
						   abaaaaaaaeaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaabaaaaaa
						   gfaaaaaddccabaaaaaaaaaaaghaaaaaepccabaaaabaaaaaaabaaaaaagiaaaaac
						   abaaaaaadcaaaaaldccabaaaaaaaaaaaegbabaaaabaaaaaaegiacaaaaaaaaaaa
						   agaaaaaaogikcaaaaaaaaaaaagaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaa
						   aaaaaaaaegiocaaaabaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
						   abaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
						   aaaaaaaaegiocaaaabaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaa
						   dcaaaaakpccabaaaabaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaaaaaaaaaa
						   egaobaaaaaaaaaaadoaaaaab"
						   }
						   SubProgram "d3d11_9x " {
							   // Stats: 5 math
							   Keywords { "B" }
							   Bind "vertex" Vertex
							   Bind "texcoord" TexCoord0
							   ConstBuffer "$Globals" 112
							   Vector 96[_MainTex_ST]
							   ConstBuffer "UnityPerDraw" 352
							   Matrix 0[glstate_matrix_mvp]
							   BindCB  "$Globals" 0
							   BindCB  "UnityPerDraw" 1
							   "vs_4_0_level_9_1
							   root12:aaacaaaa
							   eefiecedhdmejomlfakcjnjcbihghiejcnphjhejabaaaaaapiacaaaaaeaaaaaa
							   daaaaaaabiabaaaaemacaaaakaacaaaaebgpgodjoaaaaaaaoaaaaaaaaaacpopp
							   kaaaaaaaeaaaaaaaacaaceaaaaaadmaaaaaadmaaaaaaceaaabaadmaaaaaaagaa
							   abaaabaaaaaaaaaaabaaaaaaaeaaacaaaaaaaaaaaaaaaaaaaaacpoppbpaaaaac
							   afaaaaiaaaaaapjabpaaaaacafaaabiaabaaapjaaeaaaaaeaaaaadoaabaaoeja
							   abaaoekaabaaookaafaaaaadaaaaapiaaaaaffjaadaaoekaaeaaaaaeaaaaapia
							   acaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaaeaaoekaaaaakkjaaaaaoeia
							   aeaaaaaeaaaaapiaafaaoekaaaaappjaaaaaoeiaaeaaaaaeaaaaadmaaaaappia
							   aaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiappppaaaafdeieefccmabaaaa
							   eaaaabaaelaaaaaafjaaaaaeegiocaaaaaaaaaaaahaaaaaafjaaaaaeegiocaaa
							   abaaaaaaaeaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaabaaaaaa
							   gfaaaaaddccabaaaaaaaaaaaghaaaaaepccabaaaabaaaaaaabaaaaaagiaaaaac
							   abaaaaaadcaaaaaldccabaaaaaaaaaaaegbabaaaabaaaaaaegiacaaaaaaaaaaa
							   agaaaaaaogikcaaaaaaaaaaaagaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaa
							   aaaaaaaaegiocaaaabaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
							   abaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
							   aaaaaaaaegiocaaaabaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaa
							   dcaaaaakpccabaaaabaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaaaaaaaaaa
							   egaobaaaaaaaaaaadoaaaaabejfdeheoemaaaaaaacaaaaaaaiaaaaaadiaaaaaa
							   aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
							   adaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfceeaaklkl
							   epfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
							   aaaaaaaaadamaaaaebaaaaaaaaaaaaaaabaaaaaaadaaaaaaabaaaaaaapaaaaaa
							   feeffiedepepfceeaafdfgfpfaepfdejfeejepeoaaklklkl"
							   }
							   }
							   Program "fp" {
							   SubProgram "d3d11 " {
								   // Stats: 0 math, 1 textures
								   SetTexture 0[_MainTex] 2D 0
								   "ps_4_0
								   root12:abaaabaa
								   eefiecedgflpggddhopjegjmkoifcmldcdbglmahabaaaaaaceabaaaaadaaaaaa
								   cmaaaaaaieaaaaaaliaaaaaaejfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaa
								   aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaadadaaaaebaaaaaaaaaaaaaaabaaaaaa
								   adaaaaaaabaaaaaaapaaaaaafeeffiedepepfceeaafdfgfpfaepfdejfeejepeo
								   aaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
								   adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcgeaaaaaa
								   eaaaaaaabjaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaaaaaaaaaa
								   ffffaaaagcbaaaaddcbabaaaaaaaaaaagfaaaaadpccabaaaaaaaaaaaefaaaaaj
								   pccabaaaaaaaaaaaegbabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaa
								   doaaaaab"
								   }
								   SubProgram "d3d11_9x " {
									   // Stats: 0 math, 1 textures
									   SetTexture 0[_MainTex] 2D 0
									   "ps_4_0_level_9_1
									   root12:abaaabaa
									   eefiecedopcbpnkjfknaadofbpidodpmploejmgbabaaaaaajeabaaaaaeaaaaaa
									   daaaaaaajmaaaaaaaiabaaaagaabaaaaebgpgodjgeaaaaaageaaaaaaaaacpppp
									   dmaaaaaaciaaaaaaaaaaciaaaaaaciaaaaaaciaaabaaceaaaaaaciaaaaaaaaaa
									   aaacppppbpaaaaacaaaaaaiaaaaaadlabpaaaaacaaaaaajaaaaiapkaecaaaaad
									   aaaacpiaaaaaoelaaaaioekaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefc
									   geaaaaaaeaaaaaaabjaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaa
									   aaaaaaaaffffaaaagcbaaaaddcbabaaaaaaaaaaagfaaaaadpccabaaaaaaaaaaa
									   efaaaaajpccabaaaaaaaaaaaegbabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaa
									   aaaaaaaadoaaaaabejfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaa
									   aaaaaaaaadaaaaaaaaaaaaaaadadaaaaebaaaaaaaaaaaaaaabaaaaaaadaaaaaa
									   abaaaaaaapaaaaaafeeffiedepepfceeaafdfgfpfaepfdejfeejepeoaaklklkl
									   epfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
									   aaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
									   }
									   SubProgram "d3d11 " {
										   // Stats: 0 math, 1 textures
										   Keywords { "A" }
										   SetTexture 0[_MainTex] 2D 0
										   "ps_4_0
										   root12:abaaabaa
										   eefiecedgflpggddhopjegjmkoifcmldcdbglmahabaaaaaaceabaaaaadaaaaaa
										   cmaaaaaaieaaaaaaliaaaaaaejfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaa
										   aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaadadaaaaebaaaaaaaaaaaaaaabaaaaaa
										   adaaaaaaabaaaaaaapaaaaaafeeffiedepepfceeaafdfgfpfaepfdejfeejepeo
										   aaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
										   adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcgeaaaaaa
										   eaaaaaaabjaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaaaaaaaaaa
										   ffffaaaagcbaaaaddcbabaaaaaaaaaaagfaaaaadpccabaaaaaaaaaaaefaaaaaj
										   pccabaaaaaaaaaaaegbabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaa
										   doaaaaab"
										   }
										   SubProgram "d3d11_9x " {
											   // Stats: 0 math, 1 textures
											   Keywords { "A" }
											   SetTexture 0[_MainTex] 2D 0
											   "ps_4_0_level_9_1
											   root12:abaaabaa
											   eefiecedopcbpnkjfknaadofbpidodpmploejmgbabaaaaaajeabaaaaaeaaaaaa
											   daaaaaaajmaaaaaaaiabaaaagaabaaaaebgpgodjgeaaaaaageaaaaaaaaacpppp
											   dmaaaaaaciaaaaaaaaaaciaaaaaaciaaaaaaciaaabaaceaaaaaaciaaaaaaaaaa
											   aaacppppbpaaaaacaaaaaaiaaaaaadlabpaaaaacaaaaaajaaaaiapkaecaaaaad
											   aaaacpiaaaaaoelaaaaioekaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefc
											   geaaaaaaeaaaaaaabjaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaa
											   aaaaaaaaffffaaaagcbaaaaddcbabaaaaaaaaaaagfaaaaadpccabaaaaaaaaaaa
											   efaaaaajpccabaaaaaaaaaaaegbabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaa
											   aaaaaaaadoaaaaabejfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaa
											   aaaaaaaaadaaaaaaaaaaaaaaadadaaaaebaaaaaaaaaaaaaaabaaaaaaadaaaaaa
											   abaaaaaaapaaaaaafeeffiedepepfceeaafdfgfpfaepfdejfeejepeoaaklklkl
											   epfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
											   aaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
											   }
											   SubProgram "d3d11 " {
												   // Stats: 0 math, 1 textures
												   Keywords { "B" }
												   SetTexture 0[_MainTex] 2D 0
												   "ps_4_0
												   root12:abaaabaa
												   eefiecedgflpggddhopjegjmkoifcmldcdbglmahabaaaaaaceabaaaaadaaaaaa
												   cmaaaaaaieaaaaaaliaaaaaaejfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaa
												   aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaadadaaaaebaaaaaaaaaaaaaaabaaaaaa
												   adaaaaaaabaaaaaaapaaaaaafeeffiedepepfceeaafdfgfpfaepfdejfeejepeo
												   aaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
												   adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcgeaaaaaa
												   eaaaaaaabjaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaaaaaaaaaa
												   ffffaaaagcbaaaaddcbabaaaaaaaaaaagfaaaaadpccabaaaaaaaaaaaefaaaaaj
												   pccabaaaaaaaaaaaegbabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaa
												   doaaaaab"
												   }
												   SubProgram "d3d11_9x " {
													   // Stats: 0 math, 1 textures
													   Keywords { "B" }
													   SetTexture 0[_MainTex] 2D 0
													   "ps_4_0_level_9_1
													   root12:abaaabaa
													   eefiecedopcbpnkjfknaadofbpidodpmploejmgbabaaaaaajeabaaaaaeaaaaaa
													   daaaaaaajmaaaaaaaiabaaaagaabaaaaebgpgodjgeaaaaaageaaaaaaaaacpppp
													   dmaaaaaaciaaaaaaaaaaciaaaaaaciaaaaaaciaaabaaceaaaaaaciaaaaaaaaaa
													   aaacppppbpaaaaacaaaaaaiaaaaaadlabpaaaaacaaaaaajaaaaiapkaecaaaaad
													   aaaacpiaaaaaoelaaaaioekaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefc
													   geaaaaaaeaaaaaaabjaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaa
													   aaaaaaaaffffaaaagcbaaaaddcbabaaaaaaaaaaagfaaaaadpccabaaaaaaaaaaa
													   efaaaaajpccabaaaaaaaaaaaegbabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaa
													   aaaaaaaadoaaaaabejfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaa
													   aaaaaaaaadaaaaaaaaaaaaaaadadaaaaebaaaaaaaaaaaaaaabaaaaaaadaaaaaa
													   abaaaaaaapaaaaaafeeffiedepepfceeaafdfgfpfaepfdejfeejepeoaaklklkl
													   epfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
													   aaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
													   }
													   }
														}
	}
}