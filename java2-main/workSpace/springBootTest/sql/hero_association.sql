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

-- ============================================================
-- 5. 首页四大板块数据表
--    以下表只做 CREATE TABLE IF NOT EXISTS，可重复执行
--    注意：重新跑本文件仍会 DROP TABLE t_user（第 2 节的原有行为），
--          若只想重建下面四张表，请单独执行第 5~6 节
-- ============================================================

-- 5.1 英雄名录
CREATE TABLE IF NOT EXISTS t_hero (
    id           VARCHAR(16)  NOT NULL                COMMENT '英雄编号（如 h-01）',
    name         VARCHAR(64)  NOT NULL                COMMENT '英雄代号',
    alias        VARCHAR(64)  DEFAULT NULL            COMMENT '别名/别称，用于检索',
    `level`      CHAR(1)      NOT NULL DEFAULT 'C'    COMMENT '等级：C/B/A/S',
    affiliation  VARCHAR(32)  DEFAULT NULL            COMMENT '所属支部',
    ability      VARCHAR(128) DEFAULT NULL            COMMENT '能力/招式',
    `weight`     INT          NOT NULL DEFAULT 0      COMMENT '战力权重，用于排序',
    `ts`         BIGINT       NOT NULL DEFAULT 0      COMMENT '排序用时间权重',
    PRIMARY KEY (id),
    KEY idx_hero_level (`level`),
    KEY idx_hero_affiliation (affiliation)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COMMENT = '英雄名录';

-- 5.2 怪人档案
CREATE TABLE IF NOT EXISTS t_monster (
    id           VARCHAR(16)  NOT NULL                COMMENT '怪人编号（如 m-01）',
    name         VARCHAR(64)  NOT NULL                COMMENT '怪人名称',
    `level`      VARCHAR(8)   NOT NULL DEFAULT '狼'    COMMENT '灾害级：狼/虎/鬼/龙/神',
    habitat      VARCHAR(32)  DEFAULT NULL            COMMENT '出没地',
    `status`     VARCHAR(16)  DEFAULT NULL            COMMENT '状态：在逃/已讨伐/收容中',
    feature      VARCHAR(128) DEFAULT NULL            COMMENT '特征描述',
    `weight`     INT          NOT NULL DEFAULT 0      COMMENT '威胁权重，用于排序',
    `ts`         BIGINT       NOT NULL DEFAULT 0      COMMENT '排序用时间权重',
    PRIMARY KEY (id),
    KEY idx_monster_level (`level`),
    KEY idx_monster_status (`status`),
    KEY idx_monster_habitat (habitat)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COMMENT = '怪人档案';

-- 5.3 灾害警报
CREATE TABLE IF NOT EXISTS t_disaster (
    id           VARCHAR(16)  NOT NULL                COMMENT '警报编号（如 d-01）',
    name         VARCHAR(64)  NOT NULL                COMMENT '灾害名称',
    `level`      VARCHAR(8)   NOT NULL DEFAULT '狼'    COMMENT '灾害级：狼/虎/鬼/龙',
    `status`     VARCHAR(16)  DEFAULT NULL            COMMENT '状态：处理中/已平息/警戒中',
    `location`   VARCHAR(32)  DEFAULT NULL            COMMENT '发生地点',
    detail       VARCHAR(255) DEFAULT NULL            COMMENT '详情描述',
    `weight`     INT          NOT NULL DEFAULT 0      COMMENT '危害权重，用于排序',
    `ts`         BIGINT       NOT NULL DEFAULT 0      COMMENT '排序用时间权重',
    PRIMARY KEY (id),
    KEY idx_disaster_level (`level`),
    KEY idx_disaster_status (`status`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COMMENT = '灾害警报';

-- 5.4 协会公告
CREATE TABLE IF NOT EXISTS t_notice (
    id           VARCHAR(16)  NOT NULL                COMMENT '公告编号（如 n-01）',
    name         VARCHAR(128) NOT NULL                COMMENT '公告标题',
    `level`      VARCHAR(8)   NOT NULL DEFAULT '普通'  COMMENT '紧急度：普通/重要/紧急',
    dept         VARCHAR(32)  DEFAULT NULL            COMMENT '发布部门',
    content      VARCHAR(255) DEFAULT NULL            COMMENT '公告正文',
    `weight`     INT          NOT NULL DEFAULT 0      COMMENT '权重，用于排序',
    `ts`         BIGINT       NOT NULL DEFAULT 0      COMMENT '排序用时间权重',
    PRIMARY KEY (id),
    KEY idx_notice_level (`level`),
    KEY idx_notice_dept (dept)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COMMENT = '协会公告';

-- ============================================================
-- 6. 四大板块数据（与前端 Bundles 一致，共 40 条）
-- ============================================================
INSERT IGNORE INTO t_hero (id, name, alias, `level`, affiliation, ability, `weight`, `ts`) VALUES
('h-01', '秃头披风侠',    '埼玉 琦玉',        'B', 'A市', '一拳必杀·认真系列',   9999,  1),
('h-02', '杰诺斯',        NULL,              'S', 'A市', '机械改造·焚烧炮',     8800,  2),
('h-03', '战栗的龙卷',    NULL,              'S', 'A市', '超能力·念动重力',     9200,  3),
('h-04', '银色獠牙',      NULL,              'S', 'S市', '流水岩碎拳',         8600,  4),
('h-05', '原子武士',      NULL,              'S', 'A市', '原子斩',             8400,  5),
('h-06', '金属球棒',      NULL,              'S', 'Y市', '气势·钢铁球棒',      7900,  6),
('h-07', '无证骑士',      NULL,              'C', 'A市', '正义感·自行车撞击',   1200,  7),
('h-08', '毒刺',          NULL,              'A', 'B市', '毒刺贯枪',           5200,  8),
('h-09', '帅气假面·甜心假面', NULL,           'A', 'A市', '怪人化·完美肉体',     6800,  9),
('h-10', '地狱的吹雪',    NULL,              'B', 'B市', '超能力·地狱岚',       6100, 10),
('h-11', '音速的索尼克',  NULL,              'S', 'S市', '忍术·风刃脚',         7500, 11),
('h-12', '背心尊者',      NULL,              'A', 'B市', '背心组统帅',         4300, 12);

INSERT IGNORE INTO t_monster (id, name, `level`, habitat, `status`, feature, `weight`, `ts`) VALUES
('m-01', '深海王',              '龙', '深海', '已讨伐', '湿润化·水压沉重打击',       8200, 21),
('m-02', '疫苗人',              '龙', 'A市',  '已讨伐', '病原体拟态·飞行射击',       7800, 22),
('m-03', '蜈蚣长老',            '龙', '地下', '在逃',   '巨型装甲·再生外壳',         9100, 23),
('m-04', '波罗斯',              '神', '天空', '已讨伐', '能量解放·流星爆发',        10000, 24),
('m-05', '梅鲁扎嘎鲁多',        '龙', '天空', '已讨伐', '五头分裂·同步再生',         7500, 25),
('m-06', '古代王',              '龙', '地下', '收容中', '地底远古霸者·热射线',       8000, 26),
('m-07', '怪人协会首领·饿狼',   '龙', 'A市',  '在逃',   '流水岩碎拳·怪害神杀拳',     9500, 27),
('m-08', '螃蟹怪',              '虎', 'A市',  '已讨伐', '钳击·离家回忆',              900, 28),
('m-09', '飞天铠虫',            '鬼', '天空', '在逃',   '群体突袭·坚硬甲壳',         3200, 29),
('m-10', '地狱犬',              '虎', '地下', '收容中', '三重撕咬',                  2600, 30),
('m-11', '长舌怪',              '狼', 'A市',  '已讨伐', '伸缩舌·缠绕',                700, 31),
('m-12', '巨臂猩猩',            '狼', '地下', '收容中', '巨臂横扫',                    950, 32);

INSERT IGNORE INTO t_disaster (id, name, `level`, `status`, `location`, detail, `weight`, `ts`) VALUES
('d-01', 'A市地面塌陷',     '龙', '已平息', 'A市', '地下空洞连锁崩落，已疏散居民',         9000, 1001),
('d-02', '陨石直击警报',    '龙', '已平息', 'A市', '巨型陨石坠落，由 S 级英雄介入化解',    9500, 1002),
('d-03', '深海族群暴走',    '鬼', '已平息', '海边', '深海族成群登陆，沿岸封锁',             4200, 1003),
('d-04', '天空王袭击',      '龙', '处理中', 'S市', '飞行怪人集群突袭，空域管制中',         8100, 1004),
('d-05', '怪人协会据点暴露', '龙', '处理中', '地下', '大规模潜伏据点，已展开清剿',          8800, 1005),
('d-06', 'Z市废墟异动',     '虎', '警戒中', 'Z市', '废墟区域出现不明能量反应',             2400, 1006),
('d-07', '大型蟑螂群扩散',  '虎', '警戒中', 'B市', '繁殖异常，已投放消杀小队',             2100, 1007),
('d-08', '市内燃气爆炸',    '狼', '已平息', 'Y市', '管道老化引发，无人员重伤',               600, 1008);

INSERT IGNORE INTO t_notice (id, name, `level`, dept, content, `weight`, `ts`) VALUES
('n-01', 'S级英雄资格审查通知', '紧急', '人事部', '本月起执行新版战力评定标准，请各位准时提交材料', 300, 2001),
('n-02', 'B级晋升考核开放报名', '重要', '人事部', '连续三次任务评级 A 以上者即可申请',               200, 2002),
('n-03', 'A市支部招募新人',     '普通', '人事部', '欢迎热爱正义的英雄报名，零基础亦可',               100, 2003),
('n-04', '怪人讨伐悬赏清单更新', '重要', '作战部', '新增三名在逃龙级怪人，赏金上调',                   200, 2004),
('n-05', '灾害避难演习安排',     '普通', '作战部', '本周六在 A 市举行全员避难演练',                     100, 2005),
('n-06', '英雄排名月度公示',     '普通', '宣传部', '排名依据为任务实绩与民众评价加权',                 100, 2006),
('n-07', '总部大楼修缮工程',     '普通', '后勤部', '东侧外墙施工，请从南门通行',                       100, 2007),
('n-08', '披风采购费用报销调整', '重要', '后勤部', '定制披风报销上限提高，凭发票办理',                 200, 2008);

-- 7. 验证四张表
SELECT 't_hero' AS 表, COUNT(*) AS 条数 FROM t_hero
UNION ALL SELECT 't_monster',  COUNT(*) FROM t_monster
UNION ALL SELECT 't_disaster', COUNT(*) FROM t_disaster
UNION ALL SELECT 't_notice',   COUNT(*) FROM t_notice;
