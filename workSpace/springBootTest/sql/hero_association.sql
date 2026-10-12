-- ============================================================
-- 一拳超人 · 英雄协会 登录注册系统
-- 数据库初始化脚本（MySQL 8.x）
-- 执行方式：mysql -uroot -p < hero_association.sql
--   或在 Navicat / DataGrip / IDEA Database 面板中直接运行
-- ============================================================

-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS hero_association
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE hero_association;

-- 2. 创建用户（英雄）表
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    username    VARCHAR(50)  NOT NULL                COMMENT '英雄代号（登录账号）',
    email       VARCHAR(100) NOT NULL                COMMENT '联络邮箱',
    password    VARCHAR(64)  NOT NULL                COMMENT '密码（MD5）',
    hero_class  CHAR(1)      NOT NULL DEFAULT 'C'    COMMENT '英雄等级：C/B/A/S',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COMMENT = '英雄（用户）表';

-- 3. 测试数据
--    所有测试账号密码均为：123456（MD5：e10adc3949ba59abbe56e057f20f883e）
INSERT INTO t_user (username, email, password, hero_class) VALUES
('秃头披风侠', 'saitama@association.com',   'e10adc3949ba59abbe56e057f20f883e', 'S'),
('杰诺斯',     'genos@association.com',     'e10adc3949ba59abbe56e057f20f883e', 'S'),
('无免骑士',   'licenseless@association.com', 'e10adc3949ba59abbe56e057f20f883e', 'C'),
('地狱的吹雪', 'fubuki@association.com',    'e10adc3949ba59abbe56e057f20f883e', 'B');

-- 4. 验证
SELECT id, username, email, hero_class, create_time FROM t_user;
