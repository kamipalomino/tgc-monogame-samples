#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

float4x4 World;
float4x4 View;
float4x4 Projection;
texture ModelTexture;

struct VertexShaderInput
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
    float2 TextureCoordinate : TEXCOORD0;
};

struct VertexShaderOutput
{
	float4 Position : SV_POSITION;
    float4 Color : COLOR0;
    float2 TextureCoordinate : TEXCOORD1;
};

sampler2D textureSampler = sampler_state
{
    Texture = (ModelTexture);
    MagFilter = Linear;
    MinFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

float Time = 0;
float3 random(in float _x){
    return frac(sin(_x)*1e4);
}
VertexShaderOutput MainVS(in VertexShaderInput input)
{
	VertexShaderOutput output = (VertexShaderOutput)0;

    float3 normalizado = normalize(input.Position.xyz)*10.0; //posicion local
    //input.Position.xyz = normalizado; // me devuelve la esfera del modelo
    float3 posicionInicial= input.Position.xyz;
    float seno =abs(sin(Time)*0.4*3.14);
    float timer = abs(Time % 2.0-1.0);
    //Tengo que interpolar lerp(a,b,c) -->a*(1-c)+b*c 
    // lerp(0,10,0.5) => 5 

    // saturate(Time) -> si es < 0 da 0 y si es >1 da 1
    
    //si uso exponencial --> t*t empieo lento y aumento la veloidad

    input.Position.xyz= lerp(posicionInicial,normalizado,saturate(seno));
   // input.Position.xyz= lerp(normalizado,posicionInicial,saturate(Time));
    
  //  input.Position.xyz= lerp(normalizado,posicionInicial,saturate(Time));
	// Animate position
    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
	
	// Project position
    output.Position = mul(viewPosition, Projection);

	// Propagate texture coordinates
    output.TextureCoordinate = input.TextureCoordinate;

	// Animate color
   // input.Color.b = abs(seno);
   // input.Color.g = abs(cos(Time * atenuacion));

	// Propagate color by vertex
    output.Color = input.Color;

    return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{
	// Get the texture texel textureSampler is the sampler, Texcoord is the interpolated coordinates
    float4 textureColor = tex2D(textureSampler, input.TextureCoordinate);
    textureColor.a = 1;
	// Color and texture are combined in this example, 80% the color of the texture and 20% that of the vertex
    return 0.8 * textureColor + 0.2 * input.Color;
}

technique BasicColorDrawing
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};
