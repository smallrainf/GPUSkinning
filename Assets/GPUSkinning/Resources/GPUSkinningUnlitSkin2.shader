Shader "GPUSkinning/GPUSkinning_Unlit_Skin2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_ShadowColor("ShadowColor", Color) = (0,0,0,1)
		_LightDir("LightDirection", Vector) = (0,0,0,0)
		_ShadowFalloff("ShadowFalloff", Range(0,1)) = 0
		_Height("Height", Float) = 1
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "AlphaTest+10" }
		LOD 200

		Cull Back

		Pass
		{
			Stencil
			{
				Ref 2
				Comp Always
				Pass Replace
			}

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			//#pragma multi_compile ROOTON_BLENDOFF ROOTON_BLENDON_CROSSFADEROOTON ROOTON_BLENDON_CROSSFADEROOTOFF ROOTOFF_BLENDOFF ROOTOFF_BLENDON_CROSSFADEROOTON ROOTOFF_BLENDON_CROSSFADEROOTOFF
			#pragma shader_feature ROOTOFF_BLENDOFF ROOTOFF_BLENDON_CROSSFADEROOTOFF

			#include "UnityCG.cginc"
			#include "Assets/GPUSkinning/Resources/GPUSkinningInclude.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 uv2 : TEXCOORD1;
				float4 uv3 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				fixed3 col : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v) {
				UNITY_SETUP_INSTANCE_ID(v);

				v2f o;

				float4 pos = skin2(v.vertex, v.uv2, v.uv3);

				o.vertex = UnityObjectToClipPos(pos);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.col = getColor();
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 tex = tex2D(_MainTex, i.uv);
				fixed3 col = tex.rgb * (1 - tex.a) + tex.rgb * tex.a * i.col;
				return fixed4(col, 1);
			}

			ENDCG
		}

		Pass
		{
			Stencil
			{
				Ref 0
				Comp equal
				Pass IncrWrap
				Fail keep
				ZFail keep
			}

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

			Offset -1, 0

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			//#pragma multi_compile ROOTON_BLENDOFF ROOTON_BLENDON_CROSSFADEROOTON ROOTON_BLENDON_CROSSFADEROOTOFF ROOTOFF_BLENDOFF ROOTOFF_BLENDON_CROSSFADEROOTON ROOTOFF_BLENDON_CROSSFADEROOTOFF
			#pragma shader_feature ROOTOFF_BLENDOFF ROOTOFF_BLENDON_CROSSFADEROOTOFF

			#include "UnityCG.cginc"
			#include "Assets/GPUSkinning/Resources/GPUSkinningInclude.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 uv2 : TEXCOORD1;
				float4 uv3 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				fixed4 color : COLOR;
				float4 vertex : SV_POSITION;
			};

			half4 _LightDir;
			half4 _ShadowColor;
			fixed _ShadowFalloff;
			half _Height;

			v2f vert(appdata v) {
				UNITY_SETUP_INSTANCE_ID(v);

				v2f o;

				float4 pos = skin2(v.vertex, v.uv2, v.uv3);

				float3 worldPos = mul(unity_ObjectToWorld, pos).xyz;
				fixed3 lightDir = normalize(_LightDir.xyz);

				float4 shadowPos;
				shadowPos.y = min(worldPos.y, _LightDir.w);
				shadowPos.xz = worldPos.xz - lightDir.xz * max(0, worldPos.y - _LightDir.w) / lightDir.y;

				half3 modelHeight = float3(unity_ObjectToWorld[0].w, _Height, unity_ObjectToWorld[2].w);

				half3 shadowH;
				shadowH.y = shadowPos.y;
				shadowH.xz = modelHeight.xz - lightDir.xz * max(0, modelHeight.y - _LightDir.w) / lightDir.y;

				half3 center = float3(unity_ObjectToWorld[0].w, _LightDir.w, unity_ObjectToWorld[2].w);

				o.vertex = UnityWorldToClipPos(shadowPos);

				half pixelLength = distance(shadowPos, center);
				half totalLength = distance(shadowH, center);
				fixed percent = pixelLength / totalLength;
				fixed falloff = 1 - saturate(percent * _ShadowFalloff);

				o.color = _ShadowColor;
				o.color.a *= falloff;
				o.color.rgb *= o.color.a;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = i.color;
				return col;
			}

			ENDCG
		}
	}
}
