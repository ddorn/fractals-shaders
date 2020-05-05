#version 330

precision highp float;

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
#define phase(z) z.x > 0 ? atan(z.x, z.y) : -atan(z.x, z.y)

in vec2 z0;
out vec4 fragColor;

uniform float u_time;
uniform float u_limit;
uniform float u_bound;
uniform float u_stride;
uniform int u_kind;

float smooth_part(vec2 z, float bound) {

    float length_z = length(z);
    float r = (abs(length_z - 1.0) < 0.1) ? 0.0 : 1.0 + log(log(bound) / abs(log(length_z))) / log(2.0);
    return r;
}

float steps(vec2 z0, float maxi, float bound) {
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
    vec2 z = z0;
    float i;
    for (i = 0; i < maxi; ++i) {
        z = cproduct(z, z) + z0;
        if (length(z) > bound) {
            return (i + smooth_part(z, bound)) / maxi;
        }
    }
    return 1.0;
}

float smooth_fire(vec2 z0, float maxi, float bound) {
    vec2 z = z0;
    float abs_z0 = length(z0);
    float s = 0;
    float old_s = 0;
    float i, m, M, z_diff, length_z;
    for (i = 1; i < maxi; ++i) {
        z = cproduct(z, z) + z0;

        old_s = s;
        z_diff = length(z - z0);
        m = abs(z_diff - abs_z0);
        M = z_diff + abs_z0;

        length_z = length(z);
        if (i > 1 && M != m) {
            s += (length_z - m) / (M - m);
        }

        if (length_z > bound) {
            break;
        }
    }

    float S = (i > 1) ? s / (i - 1) : 0;
    float OLD_S = (i > 2) ? old_s / (i - 2) : 0;

    return mix(OLD_S, S, smooth_part(z, bound));
}

float escape_stride(vec2 z0, float stride, float maxi, float bound) {

    float sum = 0.0;
    float sum_old = 0.0;
    vec2 z = z0;
    float i;
    for (i = 0.0; i < maxi; ++i) {
        z = cproduct(z, z) + z0;
        sum_old = sum;
        sum += 0.5 * sin(stride * phase(z)) + 0.5;
        if (length(z) > bound) {
            break;
        }
    }

    float S = (i > 1) ? sum / (i - 1) : 0;
    float OLD_S = (i > 2) ? sum_old / (i - 2) : 0;

    return mix(OLD_S, S, smooth_part(z, bound));
}

void main() {

    float v;
    switch (u_kind) {
        case 1:
            v = smooth_steps(z0, u_limit, u_bound);
            break;
        case 2:
            v = smooth_fire(z0, u_limit, u_bound);
            break;
        case 3:
            v = escape_stride(z0, u_stride, u_limit, u_bound);
            break;
        default:
            v = steps(z0, u_limit, u_bound);
    }

    vec3 color = vec3(abs(sin(u_time)), abs(cos(u_time + 1)), abs(sin(2.21324321 * u_time - 1)));
    fragColor = vec4(v * color, 1);
}
#endif
