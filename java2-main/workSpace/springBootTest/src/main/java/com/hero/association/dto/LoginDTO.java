package com.hero.association.dto;

import lombok.Data;

/**
 * 登录入参：{ username, password }
 */
@Data
public class LoginDTO {

    private String username;

    private String password;
}
