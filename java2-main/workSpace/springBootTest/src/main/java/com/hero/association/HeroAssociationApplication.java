package com.hero.association;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 一拳超人·英雄协会 登录注册系统启动类
 */
@SpringBootApplication
@MapperScan("com.hero.association.mapper")
public class HeroAssociationApplication {

    public static void main(String[] args) {
        SpringApplication.run(HeroAssociationApplication.class, args);
        System.out.println("\n============================================");
        System.out.println("  英雄协会后端已启动: http://localhost:8080");
        System.out.println("  登录接口: POST /api/login");
        System.out.println("  注册接口: POST /api/register");
        System.out.println("============================================\n");
    }
}
