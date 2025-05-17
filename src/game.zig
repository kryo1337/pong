pub const Paddle = struct {
    x: f32,
    y: f32,
    width: f32 = 10,
    height: f32 = 100,
    speed: f32 = 5,
    score: u32 = 0,

    pub fn moveUp(self: *Paddle) void {
        self.y -= self.speed;
        if (self.y < 0) self.y = 0;
    }

    pub fn moveDown(self: *Paddle, canvas_height: f32) void {
        self.y += self.speed;
        if (self.y + self.height > canvas_height) {
            self.y = canvas_height - self.height;
        }
    }
};

pub const Ball = struct {
    x: f32,
    y: f32,
    radius: f32 = 5,
    speed_x: f32 = 1,
    speed_y: f32 = 1,

    pub fn update(self: *Ball, canvas_width: f32, canvas_height: f32) void {
        self.x += self.speed_x;
        self.y += self.speed_y;

        if (self.y <= 0 or self.y >= canvas_height) {
            self.speed_y = -self.speed_y;
        }

        if (self.x <= 0 or self.x >= canvas_width) {
            self.speed_x = -self.speed_x;
        }
    }

    pub fn reset(self: *Ball, canvas_width: f32, canvas_height: f32) void {
        self.x = canvas_width / 2;
        self.y = canvas_height / 2;
        self.speed_x = -self.speed_x;
        self.speed_y = if (self.speed_y > 0) -5 else 5;
    }
};

pub const Game = struct {
    left_paddle: Paddle,
    right_paddle: Paddle,
    ball: Ball,
    canvas_width: f32,
    canvas_height: f32,

    pub fn init(canvas_width: f32, canvas_height: f32) Game {
        return Game{
            .left_paddle = Paddle{
                .x = 20,
                .y = canvas_height / 2 - 50,
            },
            .right_paddle = Paddle{
                .x = canvas_width - 30,
                .y = canvas_height / 2 - 50,
            },
            .ball = Ball{
                .x = canvas_width / 2,
                .y = canvas_height / 2,
            },
            .canvas_width = canvas_width,
            .canvas_height = canvas_height,
        };
    }

    pub fn update(self: *Game) void {
        self.ball.update(self.canvas_width, self.canvas_height);

        if (self.ball.x <= self.left_paddle.x + self.left_paddle.width and
            self.ball.y >= self.left_paddle.y and
            self.ball.y <= self.left_paddle.y + self.left_paddle.height)
        {
            self.ball.speed_x = -self.ball.speed_x;
            self.ball.x = self.left_paddle.x + self.left_paddle.width;
        }

        if (self.ball.x + self.ball.radius >= self.right_paddle.x and
            self.ball.y >= self.right_paddle.y and
            self.ball.y <= self.right_paddle.y + self.right_paddle.height)
        {
            self.ball.speed_x = -self.ball.speed_x;
            self.ball.x = self.right_paddle.x - self.ball.radius;
        }

        if (self.ball.x <= 0) {
            self.right_paddle.score += 1;
            self.ball.reset(self.canvas_width, self.canvas_height);
        }
        if (self.ball.x >= self.canvas_width) {
            self.left_paddle.score += 1;
            self.ball.reset(self.canvas_width, self.canvas_height);
        }
    }
};

