#version 330

#if defined VERTEX_SHADER

in vec2 in_position;
out vec2 z0;

uniform vec2 u_center;
uniform float u_height;
uniform vec2 u_size;

void main() {
    gl_Position = vec4(in_position, 0.0, 1.0);

    vec2 ratio = vec2(u_size.x / u_size.y, 1.0) * u_height;
    z0 = u_center + in_position * ratio;
}

#elif defined FRAGMENT_SHADER

#define cproduct(a, b) vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x)

in vec2 z0;
out vec4 fragColor;

uniform float u_time;
uniform float u_limit;
uniform float u_bound;
uniform int u_kind;

float steps(vec2 z0, float maxi, float bound) {
    bound = bound * bound;
    vec2 z = z0;
    float i;
    for (i = 0; i < maxi; ++i) {
        z = cproduct(z, z) + z0;
        if (length(z) > bound) {
            break;
        }
    }
    return i / maxi;
}

float smooth_steps(vec2 z0, float maxi, float bound) {
    bound = bound * bound;
    vec2 z = z0;
    float i;
    for (i = 0; i < maxi; ++i) {
        z = cproduct(z, z) + z0;
        if (length(z) > bound) {
            return (i + log(log(bound) / log(length(z))) / log(2)) / maxi;
        }
    }
    return 1.0;
}

void main() {

    float v;
    switch (u_kind) {
        case 1:
            v = smooth_steps(z0, u_limit, u_bound);
            break;
        default:
            v = steps(z0, u_limit, u_bound);
    }


    vec3 color = vec3(abs(sin(u_time)), abs(cos(u_time + 1)), abs(sin(2 * u_time - 1)));
    fragColor = vec4(v * color, 1);
}
#endif
