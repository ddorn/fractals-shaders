import os
from pathlib import Path
from typing import Any

import moderngl
from moderngl_window import WindowConfig
import numpy as np
from moderngl_window.context.base import KeyModifiers

from fractals_shaders.constants import *


LIMIT = int(os.environ.get("LIMIT", 100))


class Window(WindowConfig):
    gl_version = (3, 3)
    resource_dir = Path(__file__).parent.parent / "shaders"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        points = np.array(
            [1, -1, 1, 1, -1, -1, -1, 1], dtype="f4"
        )

        self.prog = self.load_program("shader.glsl")
        self.vbo = self.ctx.buffer(points)
        self.vao = self.ctx.vertex_array(
            self.prog,
            [
                (self.vbo, "2f", "in_position")
            ]
        )

        self.center = -0.25 + 0j
        self.height = 1
        self.limit = LIMIT
        self.kind = Kind.TIME_ESCAPE
        self.bound = 5000
        self.stride = 4

    def mouse_drag_event(self, x: int, y: int, dx: int, dy: int):
        self.center += (-dx + dy * 1j) * (2 * self.height / self.window_size[1])

    def mouse_scroll_event(self, x_offset: float, y_offset: float):
        zoom = 1 + y_offset * 0.2
        self.height *= zoom

    def key_event(self, key: Any, action: Any, modifiers: KeyModifiers):
        super().key_event(key, action, modifiers)

        if action == self.wnd.keys.ACTION_PRESS:
            if key == self.wnd.keys.R:
                self.limit *= 1.2
            elif key == self.wnd.keys.F:
                self.limit /= 1.2
            elif key == self.wnd.keys.TAB:
                if modifiers.shift:
                    self.kind -= 1
                else:
                    self.kind += 1
                self.kind %= Kind.MAX

    def render(self, time: float, frame_time: float):
        self.prog["u_time"] = time
        self.prog["u_size"] = self.window_size
        self.prog["u_center"] = self.center.real, self.center.imag
        self.prog["u_height"] = self.height
        self.prog["u_limit"] = self.limit
        self.prog["u_kind"] = self.kind
        self.prog["u_bound"] = self.bound
        self.prog["u_stride"] = self.stride

        self.ctx.clear(0, 0, 0)
        self.vao.render(moderngl.TRIANGLE_STRIP)


if __name__ == '__main__':
    Window.run()
