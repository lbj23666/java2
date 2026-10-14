package com.hero.association.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hero.association.common.Result;
import com.hero.association.dto.LoginDTO;
import com.hero.association.dto.RegisterDTO;
import com.hero.association.entity.User;
import com.hero.association.mapper.UserMapper;
import com.hero.association.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * 用户服务实现：登录 / 注册
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;

    /** 合法的英雄等级 */
    private static final Set<String> HERO_CLASSES = Set.of("C", "B", "A", "S");

    /** 邮箱格式 */
    private static final String EMAIL_REGEX = "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$";

    @Override
    public Result<Map<String, Object>> login(LoginDTO dto) {
        String username = trimToNull(dto.getUsername());
        String password = trimToNull(dto.getPassword());

        if (username == null || password == null) {
            return Result.error("英雄代号和密码都不能为空！");
        }

        User user = userMapper.selectOne(
                new LambdaQueryWrapper<User>().eq(User::getUsername, username));

        if (user == null) {
            return Result.error("英雄代号不存在，协会查无此人，先去注册吧！");
        }

        if (!user.getPassword().equalsIgnoreCase(md5(password))) {
            return Result.error("密码错误，连琦玉老师都不会记错密码哦");
        }

        // 登录成功，返回英雄信息
        Map<String, Object> data = new HashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("email", user.getEmail());
        data.put("heroClass", user.getHeroClass());
        return Result.success("登录成功", data);
    }

    @Override
    public Result<Void> register(RegisterDTO dto) {
        String username = trimToNull(dto.getUsername());
        String email = trimToNull(dto.getEmail());
        String password = dto.getPassword();
        String heroClass = dto.getHeroClass();

        if (username == null || email == null || password == null || password.isBlank()) {
            return Result.error("所有字段都要填写，英雄不能偷懒！");
        }
        if (!email.matches(EMAIL_REGEX)) {
            return Result.error("邮箱格式不对，协会联络不到你！");
        }
        if (password.length() < 6) {
            return Result.error("密码至少 6 位，太弱可挡不住怪人！");
        }
        if (heroClass == null || !HERO_CLASSES.contains(heroClass)) {
            heroClass = "C"; // 非法等级默认 C 级
        }

        // 代号 / 邮箱唯一性校验
        Long nameCount = userMapper.selectCount(
                new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (nameCount > 0) {
            return Result.error("该英雄代号已被登记，换一个吧！");
        }
        Long mailCount = userMapper.selectCount(
                new LambdaQueryWrapper<User>().eq(User::getEmail, email));
        if (mailCount > 0) {
            return Result.error("该邮箱已注册过账号，不能用哦！");
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(md5(password));
        user.setHeroClass(heroClass);

        try {
            userMapper.insert(user);
        } catch (DuplicateKeyException e) {
            return Result.error("该英雄代号或邮箱已被登记！");
        }

        log.info("新英雄注册成功: {}（{}级）", username, heroClass);
        return Result.success("注册成功，欢迎加入英雄协会！", null);
    }

    /** 字符串去空格，空串返回 null */
    private String trimToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    /** MD5 加密（Spring 自带工具） */
    private String md5(String raw) {
        return DigestUtils.md5DigestAsHex(raw.getBytes());
    }
}
