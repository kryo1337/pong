const game = @import("game.zig");

var game_state: ?game.Game = null;

export fn init(width: f32, height: f32) void {
    game_state = game.Game.init(width, height);
}

export fn restartGame(now: u64) callconv(.C) void {
    if (game_state) |*g| {
        g.reset();
        g.startCountdown(now);
    }
}

export fn startCountdown(now: u64) callconv(.C) void {
    if (game_state) |*g| {
        g.startCountdown(now);
    }
}

export fn getCountdown(now: u64) callconv(.C) u64 {
    if (game_state) |g| {
        if (g.is_counting_down) {
            const remaining = g.countdown_end_time - now;
            return remaining;
        }
    }
    return 0;
}

export fn isCountingDown() callconv(.C) bool {
    if (game_state) |g| {
        return g.is_counting_down;
    }
    return false;
}

export fn update(now: u64) callconv(.C) void {
    if (game_state) |*g| {
        g.update(now);
    }
}

export fn getLeftPaddleY() f32 {
    if (game_state) |g| {
        return g.left_paddle.y;
    }
    return 0;
}

export fn getRightPaddleY() f32 {
    if (game_state) |g| {
        return g.right_paddle.y;
    }
    return 0;
}

export fn getBallX() f32 {
    if (game_state) |g| {
        return g.ball.x;
    }
    return 0;
}

export fn getBallY() f32 {
    if (game_state) |g| {
        return g.ball.y;
    }
    return 0;
}

export fn getLeftScore() u32 {
    if (game_state) |g| {
        return g.left_paddle.score;
    }
    return 0;
}

export fn getRightScore() u32 {
    if (game_state) |g| {
        return g.right_paddle.score;
    }
    return 0;
}

export fn getBallSpeed() f32 {
    if (game_state) |g| {
        return @abs(g.ball.speed);
    }
    return 0;
}

export fn moveLeftPaddleUp() void {
    if (game_state) |*g| {
        g.left_paddle.moveUp();
    }
}

export fn moveLeftPaddleDown() void {
    if (game_state) |*g| {
        g.left_paddle.moveDown(g.canvas_height);
    }
}

export fn moveRightPaddleUp() void {
    if (game_state) |*g| {
        g.right_paddle.moveUp();
    }
}

export fn moveRightPaddleDown() void {
    if (game_state) |*g| {
        g.right_paddle.moveDown(g.canvas_height);
    }
}
