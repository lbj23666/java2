package com.hero.association.controller;

import com.hero.association.common.Result;
import com.hero.association.dto.LoginDTO;
import com.hero.association.dto.RegisterDTO;
import com.hero.association.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 用户控制器：前端 /api 代理到本服务的 8080 端口
 *
 * POST /api/login    登录
 * POST /api/register 注册
 */
@Slf4j
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody LoginDTO dto) {
        log.info("登录请求: {}", dto.getUsername());
        return userService.login(dto);
    }

    @PostMapping("/register")
    public Result<Void> register(@RequestBody RegisterDTO dto) {
        log.info("注册请求: {}", dto.getUsername());
        return userService.register(dto);
    }
}
