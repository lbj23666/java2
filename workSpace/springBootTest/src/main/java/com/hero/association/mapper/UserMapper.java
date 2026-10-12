package com.hero.association.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hero.association.entity.User;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户 Mapper：继承 MyBatis-Plus 的 BaseMapper，自动拥有 CRUD 方法
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {
}
