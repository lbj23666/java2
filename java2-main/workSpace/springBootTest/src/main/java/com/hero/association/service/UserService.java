package com.hero.association.service;

import com.hero.association.common.Result;
import com.hero.association.dto.LoginDTO;
import com.hero.association.dto.RegisterDTO;

import java.util.Map;

/**
 * 用户服务接口
 */
public interface UserService {

    /** 登录 */
    Result<Map<String, Object>> login(LoginDTO dto);

    /** 注册 */
    Result<Void> register(RegisterDTO dto);
}
