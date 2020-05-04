#version 330

#if defined VERTEX_SHADER

in vec2 in_position;
out vec2 z0;

void main() {
    gl_Position = vec4(in_position, 0.0, 1.0);
    z0 = in_position;
}

#elif defined FRAGMENT_SHADER

#define cproduct(a, b) vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x)

in vec2 z0;
out vec4 fragColor;

uniform float u_time;

float steps(vec2 z0, float maxi) {
    vec2 z = z0;
    float i;
    for (i = 0; i < maxi; ++i) {
        z = cproduct(z, z) + z0;
        if (length(z) > 4.0) {
            break;
        }
    }

    return i / maxi;
}

void main() {
    float s = steps(z0, 8000.);
    vec3 color = vec3(abs(sin(u_time)), abs(cos(u_time + 1)), abs(sin(2 * u_time - 1)));
    fragColor = vec4(s * color, 1);
}
#endif
