Shader "Unlit/URPHDRByCode"
{
     Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       _BlurSize ("Blur Size", Float) = 1.0
       _Param ("Parameter", Range(1, 3)) = 1
    }

    SubShader
    {
        Tags { 
            "Queue" = "Transparent"
            "IgnoreProjector" = "true" 
            "RenderType" = "Opaque" 
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
				float4 _MainTex_TexelSize;
                float _BlurSize;  
				float _Param;
            CBUFFER_END
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);  

        // 所有函数函数 与结构体全部写道subshader 
        // pass 块中直接 调用就可以
		struct img_data 
        {
            float4 positionOS : POSITION;
            half2 texcoord : TEXCOORD0;
        };
        struct appdata_t
		{
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
           // half4 color : COLOR;
		};

		struct v2f 
		{
			float4 positionHCS : SV_POSITION;
			half2 uv[5]: TEXCOORD0;
		};
        struct v2fHDR
        {
            float4 vertex : SV_POSITION;
            half2 uv : TEXCOORD0;
			half4 color : COLOR;
        };
            
        v2f vertBlurVertical(img_data IN) 
            {
			v2f OUT;
			OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
			
			half2 uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
			
			OUT.uv[0] = uv;
			OUT.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			OUT.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			OUT.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
			OUT.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
					 
			return OUT;
		}
		
		v2f vertBlurHorizontal(img_data IN)
            {
			v2f OUT;
			OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
			half2 uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
			OUT.uv[0] = uv;
			OUT.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			OUT.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			OUT.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
			OUT.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;	 
			return OUT;
		}

            half4 fragBlur(v2f IN) : SV_Target
            {
			float weight[3] = {0.4026, 0.2442, 0.0545};
			
			half3 sum = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv[0]).rgb * weight[0];
			
			for (int it = 1; it < 3; it++) {
				sum += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv[it*2-1]).rgb * weight[it];
				sum += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv[it*2]).rgb * weight[it];
			}
			
			return half4(sum, 1.0);
		    }


         float4 hdr(float4 col, float gray, float k)
            {
                float b = 4*k - 1;
                float a = 1 - b;
                float f = gray * ( a * gray + b);
                return f * col;
            }
            
            half4 frag (v2fHDR IN) : COLOR
            {
                float4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv);
                float gray = 0.3 * col.r + 0.59 * col.g + 0.11 * col.b;
                return hdr(col, gray, _Param);
            }
		
		 v2fHDR vert (appdata_t v)
            {
                v2fHDR o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv =TRANSFORM_TEX(v.uv, _MainTex);
               //o.color = v.color;
                return o;
            }
        ENDHLSL
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vertBlurVertical  
			#pragma fragment fragBlur
            ENDHLSL
        }

        pass
        {
		HLSLPROGRAM
		#pragma vertex vertBlurHorizontal  
		#pragma fragment fragBlur
		ENDHLSL
        }
            

        pass
        {
           HLSLPROGRAM
           #pragma vertex vert  
		   #pragma fragment frag
           ENDHLSL
        }
    }
        Fallback "Sprites/Default"
}
