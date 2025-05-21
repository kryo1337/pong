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
    speed: f32 = 2.0,
    base_speed: f32 = 2.0,
    speed_increase: f32 = 0.2,
    max_speed: f32 = 5.0,
    random_seed: u32 = 42,
    last_hit_frame: u32 = 0,
    direction_x: f32 = 1.0,
    direction_y: f32 = 1.0,

    fn getRandomAngle(self: *Ball) f32 {
        const angle = @as(f32, @floatFromInt(self.random_seed % 200)) / 100.0 - 1.0;
        self.random_seed = self.random_seed *% 1103515245 +% 12345;
        return angle * 0.1;
    }

    pub fn update(self: *Ball, canvas_height: f32) void {
        self.x += self.speed * self.direction_x;
        self.y += self.speed * self.direction_y;

        if (self.y <= 0) {
            self.y = 0;
            self.direction_y = 1.0;
        }
        if (self.y >= canvas_height) {
            self.y = canvas_height;
            self.direction_y = -1.0;
        }
    }

    pub fn reset(self: *Ball, canvas_width: f32, canvas_height: f32, toward_left: bool) void {
        self.x = canvas_width / 2;
        self.y = canvas_height / 2;
        self.speed = self.base_speed;
        self.direction_x = if (toward_left) -1.0 else 1.0;
        self.direction_y = 1.0;
        self.last_hit_frame = 0;
    }
};

pub const Game = struct {
    left_paddle: Paddle,
    right_paddle: Paddle,
    ball: Ball,
    canvas_width: f32,
    canvas_height: f32,
    last_scorer: enum { left, right, none } = .none,
    current_frame: u32 = 0,
    countdown_end_time: u64 = 0,
    is_counting_down: bool = false,

    pub fn init(canvas_width: f32, canvas_height: f32) Game {
        var ball = Ball{
            .x = canvas_width / 2,
            .y = canvas_height / 2,
            .base_speed = 2.0,
        };
        ball.speed = ball.base_speed;

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
            .current_frame = 0,
            .countdown_end_time = 0,
            .is_counting_down = false,
        };
    }

    pub fn startCountdown(self: *Game, now: u64) void {
        self.is_counting_down = true;
        self.countdown_end_time = now + 2000;
    }

    pub fn reset(self: *Game) void {
        self.ball.reset(self.canvas_width, self.canvas_height, true);
        self.left_paddle.y = self.canvas_height / 2 - 50;
        self.right_paddle.y = self.canvas_height / 2 - 50;
        self.left_paddle.score = 0;
        self.right_paddle.score = 0;
        self.current_frame = 0;
    }

    pub fn update(self: *Game, now: u64) void {
        self.current_frame += 1;

        if (self.is_counting_down) {
            if (now < self.countdown_end_time) {
                return;
            }
            self.is_counting_down = false;
        }

        self.ball.update(self.canvas_height);

        if (self.ball.direction_x < 0 and
            self.ball.x - self.ball.radius <= self.left_paddle.x + self.left_paddle.width and
            self.ball.x - self.ball.radius >= self.left_paddle.x - self.ball.radius and
            self.ball.y + self.ball.radius >= self.left_paddle.y and
            self.ball.y - self.ball.radius <= self.left_paddle.y + self.left_paddle.height and
            self.current_frame - self.ball.last_hit_frame > 5)
        {
            self.ball.speed = @min(self.ball.speed + self.ball.speed_increase, self.ball.max_speed);
            self.ball.direction_x = 1.0;
            self.ball.direction_y += self.ball.getRandomAngle();
            const length = @sqrt(self.ball.direction_x * self.ball.direction_x + self.ball.direction_y * self.ball.direction_y);
            self.ball.direction_x /= length;
            self.ball.direction_y /= length;
            self.ball.x = self.left_paddle.x + self.left_paddle.width + self.ball.radius;
            self.ball.last_hit_frame = self.current_frame;
        }

        if (self.ball.direction_x > 0 and
            self.ball.x + self.ball.radius >= self.right_paddle.x and
            self.ball.x + self.ball.radius <= self.right_paddle.x + self.right_paddle.width + self.ball.radius and
            self.ball.y + self.ball.radius >= self.right_paddle.y and
            self.ball.y - self.ball.radius <= self.right_paddle.y + self.right_paddle.height and
            self.current_frame - self.ball.last_hit_frame > 5)
        {
            self.ball.speed = @min(self.ball.speed + self.ball.speed_increase, self.ball.max_speed);
            self.ball.direction_x = -1.0;
            self.ball.direction_y += self.ball.getRandomAngle();
            const length = @sqrt(self.ball.direction_x * self.ball.direction_x + self.ball.direction_y * self.ball.direction_y);
            self.ball.direction_x /= length;
            self.ball.direction_y /= length;
            self.ball.x = self.right_paddle.x - self.ball.radius;
            self.ball.last_hit_frame = self.current_frame;
        }

        if (self.ball.x <= 0) {
            self.right_paddle.score += 1;
            self.last_scorer = .right;
            self.ball.reset(self.canvas_width, self.canvas_height, false);
        }
        if (self.ball.x >= self.canvas_width) {
            self.left_paddle.score += 1;
            self.last_scorer = .left;
            self.ball.reset(self.canvas_width, self.canvas_height, true);
        }
    }
};

