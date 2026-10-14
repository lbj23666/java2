package com.hero.association.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 英雄（用户）实体，对应表 t_user
 */
@Data
@TableName("t_user")
public class User {

    /** 主键，自增 */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 英雄代号（登录账号），唯一 */
    private String username;

    /** 联络邮箱，唯一 */
    private String email;

    /** 密码（MD5 存储） */
    private String password;

    /** 英雄等级：C / B / A / S */
    private String heroClass;

    /** 注册时间（数据库默认 CURRENT_TIMESTAMP） */
    private LocalDateTime createTime;

    /** 更新时间（数据库自动更新） */
    private LocalDateTime updateTime;
}
