package com.hero.association.dto;

import lombok.Data;

/**
 * 注册入参：{ username, email, password, heroClass }
 */
@Data
public class RegisterDTO {

    private String username;

    private String email;

    private String password;

    /** 英雄等级：C / B / A / S */
    private String heroClass;
}
