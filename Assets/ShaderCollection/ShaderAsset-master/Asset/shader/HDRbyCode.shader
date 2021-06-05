Shader "Unlit/HDRbyCode"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
        _Param ("Parameter", Range(1, 3)) = 1
    }
    SubShader
    {
        Tags
		{ 
			"RenderType"="Opaque" 
			"RenderPipeline" = "UniversalPipeline"
			"Queue" = "Geometry"
		}
		//#include "UnityCG.cginc"

        Pass
        {
	    HLSLINCLUDE
		//纹理的定义
		TEXTURE2D(_MainTex);
		// 采样器的定义
		SAMPLER(sampler_MainTex);
		
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		CBUFFER_START(UnityPerMaterial)
		half4 _MainTex_ST;
		float _BlurSize;
		float  _Param;
		CBUFFER_END
		ENDHLSL

		HLSLPROGRAM

        struct Attributes
         {
            float4 positionOS: POSITION;
            float2 uv : TEXCOORD0;
            half4 color : COLOR;
        };

		struct image_data
		{
			float4 vertex : POSITION;
			float2 uv: TEXCOORD0;
		};

		struct Varings {
			float3 positionCS:SV_POSITION;
			float2 uv[5]: TEXCOORD0;
		};

        struct VaringsHDR
        {
            float4 positionCS:SV_POSITION;
            float2 uv : TEXCOORD0;
			half4 color : COLOR;
        };
		  
		Varings vertBlurVertical(image_data v) {
			Varings o ; 
			VertexPositionInputs positionInputs = GetVertexPositionInputs(v.vertex.xyz);
			o.positionCS = positionInputs.positionCS
			
			//float2 uv = TRANSFORM_TEX(v.uv,_MainTex);
			
			o.uv[0] = TRANSFORM_TEX(v.uv,_MainTex);
			o.uv[1] = uv + float2(0.0, _MainTex_ST.y * 1.0) * _BlurSize;
			o.uv[2] = uv - float2(0.0, _MainTex_ST.y * 1.0) * _BlurSize;
			o.uv[3] = uv + float2(0.0, _MainTex_ST.y * 2.0) * _BlurSize;
			o.uv[4] = uv - float2(0.0, _MainTex_ST.y * 2.0) * _BlurSize;
					 
			return o;
		}
		
		Varings vertBlurHorizontal(image_data v) {
			Varings o;
			VertexPositionInputs positionInputs = GetVertexPositionInputs(v.vertex.xyz);
			o.positionCS = positionInputs.positionCS
			//half2 uv = v.texcoord;
			
			o.uv[0] = uv;
			o.uv[1] = uv + float2(_MainTex_ST.x * 1.0, 0.0) * _BlurSize;
			o.uv[2] = uv - float2(_MainTex_ST.x * 1.0, 0.0) * _BlurSize;
			o.uv[3] = uv + float2(_MainTex_ST.x * 2.0, 0.0) * _BlurSize;
			o.uv[4] = uv - float2(_MainTex_ST.x * 2.0, 0.0) * _BlurSize;
					 
			return o;
		}
		
		half4 fragBlur(Varings i) : SV_Target {
			float weight[3] = {0.4026, 0.2442, 0.0545};
			
			fixed3 sum = SAMPLE_TEXTURE2D(_MainTex, sampler_BaseMap,i.uv[0]).rgb * weight[0];
			
			for (int it = 1; it < 3; it++) {
				sum += SAMPLE_TEXTURE2D(_MainTex, sampler_BaseMap, i.uv[it*2-1]).rgb * weight[it];
				sum += SAMPLE_TEXTURE2D(_MainTex, sampler_BaseMap, i.uv[it*2]).rgb * weight[it];
			}
			
			return half4(sum, 1.0);
            
		}
        ZTest Always Cull Off ZWrite Off
		VaringsHDR vert (Attributes v)
            {
				VaringsHDR o;
                o.positionCS = GetVertexPositionInputs(v.positionOS.xyz);;
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }

        float4 hdr(float4 col, float gray, float k)
            {
                float b = 4*k - 1;
                float a = 1 - b;
                float f = gray * ( a * gray + b);
                return f * col;
            }
            
        half4 frag (VaringsHDR IN) : COLOR
            {
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_BaseMap,IN.uv);
                float gray = 0.3 * col.r + 0.59 * col.g + 0.11 * col.b;
                return hdr(col, gray, _Param);
            }
			#pragma vertex vertBlurVertical  
			#pragma fragment fragBlur
			#pragma vertex vertBlurHorizontal  
			#pragma fragment fragBlur
			#pragma vertex vert  
			#pragma fragment frag

		ENDHLSL
        }
		    
	
		
		//Pass {
		//	//NAME "GAUSSIAN_BLUR_VERTICAL"
		//	//Tags{"LightMode" = "UniversalForward"}
		//	HLSLPROGRAM
			  
		//	#pragma vertex vertBlurVertical  
		//	#pragma fragment fragBlur
			  
		//	ENDHLSL
		//}
		
		//Pass {  
		//	//NAME "GAUSSIAN_BLUR_HORIZONTAL"
		//	//Tags{"LightMode" = "UniversalForward"}
		//	HLSLPROGRAM
			
		//	#pragma vertex vertBlurHorizontal  
		//	#pragma fragment fragBlur
			
		//	ENDHLSL
		//}

  //      Pass
  //      {
		//	HLSLPROGRAM
		//	Tags{"LightMode" = "UniversalForward"}
  //          #pragma vertex vert  
		//	#pragma fragment frag
		//	ENDHLSL
  //      }
    }
    FallBack "Diffuse"
}

