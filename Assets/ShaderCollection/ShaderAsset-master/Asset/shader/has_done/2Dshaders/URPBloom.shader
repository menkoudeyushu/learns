Shader "Unlit/URPBloom"
{
     Properties
    { 
        _MainTex ("Main Texture", 2D) = "white" {}
        _Bloom ("Bloom Texture", 2D) = "black" {}
        _BlurSize ("Blur Size", Float) = 1.0
    }

    SubShader
    {
        Tags { 
            "Queue" = "Transparent"
            "IgnoreProjector" = "true" 
            "RenderType" = "Transparent" 
            "PreviewType"="Plane" 
            "CanUseSpriteAtlas"="True" 
            "RenderPipeline" = "UniversalPipeline"
             }
        // 针对2D 图像
        ZWrite Off Blend SrcAlpha OneMinusSrcAlpha Cull Off
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Bloom_ST; 
				float4 _MainTex_TexelSize;
				float4 _Bloom_TexelSize;
                float _BlurSize;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_Bloom);
            SAMPLER(sampler_Bloom);    

        // 所有函数函数 与结构体全部写道subshader 
        // pass 块中直接 调用就可以
            struct appdata_img 
            {
            float4 positionOS : POSITION;
            half2 texcoord : TEXCOORD0;
            };

            struct v2fGaussian 
            {
			float4 positionHCS : SV_POSITION;
			half2 uv[5]: TEXCOORD0;
		    };
        
            struct v2fBloom {
			    float4 positionHCS : SV_POSITION; 
			    half4 texcoord : TEXCOORD0;
		    };
            
            v2fGaussian vertBlurVertical(appdata_img IN) 
            {
			v2fGaussian OUT;
			OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
			
			half2 uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
			
			OUT.uv[0] = uv;
			OUT.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			OUT.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			OUT.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
			OUT.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
					 
			return OUT;
		    }
		
		    v2fGaussian vertBlurHorizontal(appdata_img IN)
            {
			v2fGaussian OUT;
			OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
			half2 uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
			OUT.uv[0] = uv;
			OUT.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			OUT.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			OUT.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
			OUT.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;	 
			return OUT;
		    }

            half4 fragBlur(v2fGaussian IN) : SV_Target
            {
			float weight[3] = {0.4026, 0.2442, 0.0545};
			
			half3 sum = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv[0]).rgb * weight[0];
			
			for (int it = 1; it < 3; it++) {
				sum += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv[it*2-1]).rgb * weight[it];
				sum += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv[it*2]).rgb * weight[it];
			}
			
			return half4(sum, 1.0);
		    }


        v2fBloom vertBloom(appdata_img IN) 
        {
			v2fBloom OUT;
			
			OUT.positionHCS = TransformObjectToHClip (IN.positionOS.xyz);
			OUT.texcoord.xy =  TRANSFORM_TEX(IN.texcoord.xy, _MainTex);
			OUT.texcoord.zw =  TRANSFORM_TEX(IN.texcoord.xy, _Bloom);
			// 纹理倒转
			#if UNITY_UV_STARTS_AT_TOP			
			if (_MainTex_ST.y < 0.0)
				  OUT.texcoord.w = 1.0 - OUT.texcoord.w;
			#endif
				        	
			return OUT; 
		}
		
		half4 fragBloom(v2fBloom IN) : SV_Target
		{
			return SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.texcoord.xy) + SAMPLE_TEXTURE2D(_Bloom,sampler_Bloom,IN.texcoord.zw);
		} 
        ENDHLSL
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vertBlurVertical  
			#pragma fragment fragBlur  
			#pragma vertex vertBlurHorizontal  
			#pragma fragment fragBlur
            // This macro declares _BaseMap as a Texture2D object.
            // This macro declares the sampler for the _BaseMap texture.
            ENDHLSL
        }

        pass
        {
		HLSLPROGRAM
		#pragma vertex vertBloom  
		#pragma fragment fragBloom
		ENDHLSL
        }
    }
        Fallback "Sprites/Default"
}
