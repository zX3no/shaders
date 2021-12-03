vec2 DistortPosition(in vec2 position){
    float DistortionFactor = mix(1.0f, length(position), 0.9f);
    return position.xy / DistortionFactor;
}