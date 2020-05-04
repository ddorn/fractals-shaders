from pathlib import Path

import moderngl
from moderngl_window import WindowConfig
import numpy as np


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

    def render(self, time: float, frame_time: float):
        self.prog["u_time"] = time
        self.ctx.clear(0, 0, 0)
        self.vao.render(moderngl.TRIANGLE_STRIP)


if __name__ == '__main__':
    Window.run()