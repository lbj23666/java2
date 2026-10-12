package com.hero.association.common;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理：保证任何异常都返回统一 JSON 结构，前端不至于收到 HTTP 500
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public Result<Void> handle(Exception e) {
        log.error("服务器内部异常", e);
        return Result.error("英雄协会服务器开小差了，请稍后再试");
    }
}
