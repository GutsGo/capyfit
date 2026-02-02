import 'package:flutter/material.dart';

class LevelInfo {
  final String realm; // 境界 (如: 炼气期)
  final String stage; // 段位名称 (如: 肉体凡胎)
  final String description; // 调侃描述
  final String title; // 段位称号 (如: 入门小白)
  final int stageNumber; // 第几小段 (1-5)
  final Color mainColor; // 境界主色调

  LevelInfo({
    required this.realm,
    required this.stage,
    required this.description,
    required this.title,
    required this.stageNumber,
    required this.mainColor,
  });

  String get fullDisplayName => '$realm$stageNumber段 · $stage';
}

class LevelService {
  static final List<RealmData> realms = [
    RealmData(
      name: '炼气期',
      color: const Color(0xFF9E9E9E), // 灰色
      stages: [
        StageData('肉体凡胎', 1, 3, '入门小白', '恭喜你超越了全国3%的同龄人，他们今天连床都没下'),
        StageData('初步开窍', 4, 7, '健身房游客', '已经学会假装自己是经常来健身的人了'),
        StageData('气息紊乱', 8, 14, '酸痛体验官', '现在你上下楼梯的表情应该很精彩吧'),
        StageData('小有所成', 15, 21, '假装自律', '你的朋友圈健身打卡已经坚持两周了，再坚持一周就能获得“坚持不懈”成就'),
        StageData('炼气圆满', 22, 30, '健身房钉子户', '好家伙，你居然真的坚持了一个月！这是要逆天改命啊'),
      ],
    ),
    RealmData(
      name: '筑基期',
      color: const Color(0xFF42A5F5), // 蓝色
      stages: [
        StageData('筋骨初成', 31, 45, '赘肉抵抗者', '你的内脏脂肪开始对你刮目相开了'),
        StageData('气血通畅', 46, 60, '健身房常客', '前台小姐姐已经认识你了，还以为你是附近写字楼的白领'),
        StageData('丹田小成', 61, 75, '硬拉入门僧', '终于能把杠铃从地上拉起来了，可喜可贺'),
        StageData('铜皮铁骨', 76, 90, '酸痛绝缘体', '健身后第二天不再像被卡车碾过了，恭喜恭喜'),
        StageData('筑基圆满', 91, 105, '初级自律怪', '你的朋友们开始问你是不是吃了什么灵丹妙药'),
      ],
    ),
    RealmData(
      name: '金丹期',
      color: const Color(0xFFCD7F32), // 青铜色/古铜色
      stages: [
        StageData('金丹初凝', 106, 120, '线条追踪者', '你已经能看出肱二头肌的轮廓了，虽然只有一点点'),
        StageData('金丹稳固', 121, 150, '腹肌隐现者', '你的腹肌正在赶来的路上，预计还有半年到达战场'),
        StageData('金丹大成', 151, 180, '健身房网红', '你的健身照终于有人评论“大佬”了，虽然是在调侃'),
        StageData('金丹圆满', 181, 210, '自律达人', '你已经开始嫌弃那些不健身的人了，虽然你以前也这样'),
        StageData('假丹境界', 211, 240, '凡尔赛大师', '你开始发愁腹肌太明显不太好意思脱衣服了'),
      ],
    ),
    RealmData(
      name: '元婴期',
      color: const Color(0xFF9C27B0), // 紫色
      stages: [
        StageData('元婴初成', 241, 270, '健身房门面', '你的存在提升了整家健身房的平均颜值水平'),
        StageData('元婴稳固', 271, 300, '行走的荷尔蒙', '开始有人问你是不是练体育的了，虽然你只是普通上班族'),
        StageData('元婴大成', 301, 350, '私教终结者', '你已经比大部分私教练得好了，他们只是理论知识比你丰富'),
        StageData('元婴圆满', 351, 400, '健身房传说', '新来的会员以为你是馆长的亲戚，其实你只是来健身的'),
        StageData('化婴征兆', 401, 450, '身材焦虑者', '你开始焦虑为什么还没练出理想身材，殊不知在外人看来你已经很好'),
      ],
    ),
    RealmData(
      name: '化神期',
      color: const Color(0xFFFF9800), // 橙色
      stages: [
        StageData('神识初显', 451, 500, '健身圈大佬', '你的训练视频开始被健身博主盗用了'),
        StageData('神通广大', 501, 550, '健身房King', '你的训练重量让新手不敢靠近，深怕被砸到'),
        StageData('神游天外', 551, 600, '完美身材持有者', '你已经达到了“穿衣显瘦，脱衣有肉”的终极形态'),
        StageData('化身圆满', 601, 650, '健身哲学家', '你开始思考健身的意义到底是什么，并且真的想明白了'),
        StageData(
          '大乘契机',
          651,
          700,
          '健身毒鸡汤手',
          '你开始在网上发那些“坚持就是胜利”的鸡汤文，被以前的自己看到会笑死',
        ),
      ],
    ),
    RealmData(
      name: '大乘期',
      color: const Color(0xFFFFD700), // 金色
      stages: [
        StageData('功德圆满', 701, 800, '健身活化石', '你的健身卡已经比很多健身房的年龄还大了'),
        StageData('返璞归真', 801, 900, '身材标杆', '你的身材照被健身房印成海报挂在门口，你都不好意思去练了'),
        StageData('超凡入圣', 901, 1000, '健身教父', '开始有人不远万里来你的城市，只为看你练一次'),
        StageData('渡劫前期', 1001, 1100, '陆地神仙', '你已经超越了99.9%的同龄人，包括那些比你年轻的'),
        StageData('渡劫在即', 1101, 1200, '半步飞升', '你的故事开始出现在健身房的传奇故事里，虽然你还在练'),
      ],
    ),
    RealmData(
      name: '渡劫飞升',
      color: const Color(0xFFE91E63), // 玫瑰红/彩虹色意向
      stages: [
        StageData('天雷降临', 1201, 1300, '准仙人', '你已经连续健身超过三年了，说实话这本身就是个奇迹'),
        StageData('心魔缠身', 1301, 1400, '孤独求败', '你开始觉得普通健身已经没意思了，考虑要不要去跑个马拉松'),
        StageData('九雷轰顶', 1401, 1500, '健身界活化石', '你的健身年限已经超过了很多健身房的营业时间'),
        StageData('仙界来接', 1501, 1800, '永恒传说', '你的名字开始出现在各种健身榜单上，尽管你从不参加任何比赛'),
        StageData('羽化登仙', 1800, 99999, '健身仙人', '你成功了，你已经是神一样的存在了'),
      ],
    ),
  ];

  static LevelInfo getLevelInfo(int days) {
    for (var realm in realms) {
      for (int i = 0; i < realm.stages.length; i++) {
        var stage = realm.stages[i];
        if (days >= stage.minDays && (days <= stage.maxDays)) {
          return LevelInfo(
            realm: realm.name,
            stage: stage.name,
            description: stage.description,
            title: stage.title,
            stageNumber: i + 1,
            mainColor: realm.color,
          );
        }
      }
    }
    // Default fallback
    return LevelInfo(
      realm: '炼气期',
      stage: '肉体凡胎',
      description: '恭喜你超越了全国3%的同龄人，他们今天连床都没下',
      title: '入门小白',
      stageNumber: 1,
      mainColor: const Color(0xFF9E9E9E),
    );
  }
}

class RealmData {
  final String name;
  final Color color;
  final List<StageData> stages;

  RealmData({required this.name, required this.color, required this.stages});
}

class StageData {
  final String name;
  final int minDays;
  final int maxDays;
  final String title;
  final String description;

  StageData(
    this.name,
    this.minDays,
    this.maxDays,
    this.title,
    this.description,
  );
}
