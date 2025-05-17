pub const Paddle = struct {
    x: f32,
    y: f32,
    width: f32 = 10,
    height: f32 = 100,
    speed: f32 = 4,
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
    speed_x: f32 = 2.5,
    speed_y: f32 = 2.5,
    base_speed: f32 = 2.5,
    speed_increase: f32 = 0.1,
    random_seed: u32 = 42,

    pub fn update(self: *Ball, canvas_height: f32) void {
        self.x += self.speed_x;
        self.y += self.speed_y;

        if (self.y <= 0) {
            self.y = 0;
            self.speed_y = -self.speed_y;
            self.speed_y += @as(f32, @floatFromInt(self.random_seed % 200)) / 100.0 - 1.0;
            self.random_seed = self.random_seed *% 1103515245 +% 12345;
        }
        if (self.y >= canvas_height) {
            self.y = canvas_height;
            self.speed_y = -self.speed_y;
            self.speed_y += @as(f32, @floatFromInt(self.random_seed % 200)) / 100.0 - 1.0;
            self.random_seed = self.random_seed *% 1103515245 +% 12345;
        }
    }

    pub fn reset(self: *Ball, canvas_width: f32, canvas_height: f32, toward_left: bool) void {
        self.x = canvas_width / 2;
        self.y = canvas_height / 2;
        self.speed_x = if (toward_left) -self.base_speed else self.base_speed;
        self.speed_y = @as(f32, @floatFromInt(self.random_seed % 100)) / 100.0 - 0.5;
        self.random_seed = self.random_seed *% 1103515245 +% 12345;
    }
};

pub const Game = struct {
    left_paddle: Paddle,
    right_paddle: Paddle,
    ball: Ball,
    canvas_width: f32,
    canvas_height: f32,
    last_scorer: enum { left, right, none } = .none,

    pub fn init(canvas_width: f32, canvas_height: f32) Game {
        var ball = Ball{
            .x = canvas_width / 2,
            .y = canvas_height / 2,
            .base_speed = 2.5,
        };
        ball.speed_x = ball.base_speed;
        ball.speed_y = ball.base_speed;

        return Game{
            .left_paddle = Paddle{
                .x = 30,
                .y = canvas_height / 2 - 50,
            },
            .right_paddle = Paddle{
                .x = canvas_width - 40,
                .y = canvas_height / 2 - 50,
            },
            .ball = ball,
            .canvas_width = canvas_width,
            .canvas_height = canvas_height,
            .last_scorer = .none,
        };
    }

    pub fn update(self: *Game) void {
        self.ball.update(self.canvas_height);

        if (self.ball.x <= self.left_paddle.x + self.left_paddle.width and
            self.ball.y >= self.left_paddle.y and
            self.ball.y <= self.left_paddle.y + self.left_paddle.height)
        {
            const hit_pos = (self.ball.y - self.left_paddle.y) / self.left_paddle.height;
            self.ball.speed_y = (hit_pos - 0.5) * 5.0;
            self.ball.speed_x = -self.ball.speed_x * (1 + self.ball.speed_increase);
            self.ball.x = self.left_paddle.x + self.left_paddle.width;
        }

        if (self.ball.x + self.ball.radius >= self.right_paddle.x and
            self.ball.y >= self.right_paddle.y and
            self.ball.y <= self.right_paddle.y + self.right_paddle.height)
        {
            const hit_pos = (self.ball.y - self.right_paddle.y) / self.right_paddle.height;
            self.ball.speed_y = (hit_pos - 0.5) * 5.0;
            self.ball.speed_x = -self.ball.speed_x * (1 + self.ball.speed_increase);
            self.ball.x = self.right_paddle.x - self.ball.radius;
        }

        if (self.ball.x <= 0) {
            self.right_paddle.score += 1;
            self.last_scorer = .right;
            self.ball.reset(self.canvas_width, self.canvas_height, false);
            self.ball.speed_x = self.ball.base_speed;
            self.ball.speed_y = self.ball.base_speed;
        }
        if (self.ball.x >= self.canvas_width) {
            self.left_paddle.score += 1;
            self.last_scorer = .left;
            self.ball.reset(self.canvas_width, self.canvas_height, true);
            self.ball.speed_x = -self.ball.base_speed;
            self.ball.speed_y = self.ball.base_speed;
        }
    }
};

