import '../models/tile_model.dart';
import '../models/player_model.dart';
import 'tile_type_detector.dart';

/// 结算计算器 - 负责计算胡牌后的点数
class SettlementCalculator {
  /// 固定点数牌型
  static const Map<HuType, int> fixedPoints = {
    HuType.qingYiSe: 10,
    HuType.fengYiSe: 20,
    HuType.fengPon: 40,
    HuType.qingPon: 40,
  };
  
  /// 无花自摸固定点数
  static const int noFlowerSelfDrawPoints = 10;
  
  /// 杠开固定点数
  static const int kaiGangPoints = 10;
  
  /// 计算胡牌点数
  static int calculatePoints({
    required HuType huType,
    required Player winner,
    required int roundMultiplier,
    required int globalMultiplier,
    required bool isSelfDrawn,
    required bool isKaiGang,
    required bool isNoFlowerSelfDraw,
    bool hasWildTile = true,
    bool isMenQing = false,
  }) {
    // 1. 先检查固定点数牌型
    final fixed = fixedPoints[huType] ?? 0;
    int basePoints;
    
    if (fixed > 0) {
      basePoints = fixed;
    } else if (isNoFlowerSelfDraw && isSelfDrawn) {
      // 无花自摸
      basePoints = noFlowerSelfDrawPoints;
    } else {
      // 2. 公式计算
      basePoints = 2; // 基础分
      basePoints += winner.flowerTiles.length; // 花牌
      basePoints += _calculateMeldPoints(winner); // 组合牌点数
    }
    
    // 3. 杠开点数
    if (isKaiGang) {
      basePoints += kaiGangPoints;
    }
    
    // 4. 自摸加1点
    if (isSelfDrawn) {
      basePoints += 1;
    }
    
    // 5. 计算额外翻倍
    int extraMultiplier = 1;
    if (!hasWildTile) extraMultiplier *= 2; // 无百搭×2
    if (isMenQing) extraMultiplier *= 2; // 门清×2
    
    // 6. 最终点数
    return basePoints * roundMultiplier * globalMultiplier * extraMultiplier;
  }
  
  /// 计算门口牌的点数
  static int _calculateMeldPoints(Player player) {
    int points = 0;
    
    // 明刻子
    for (final meld in player.exposedMelds) {
      if (meld.length == 3) {
        if (meld.first.isFeng) {
          points += 1; // 风牌刻子
        } else if (meld.first.isJian) {
          points += 2; // 箭牌刻子
        }
      }
      if (meld.length == 4) {
        // 明杠
        if (meld.first.isFeng) {
          points += 2; // 风牌杠
        } else if (meld.first.isJian) {
          points += 3; // 箭牌杠
        } else {
          points += 1; // 其他牌杠
        }
      }
    }
    
    // 暗杠
    for (final meld in player.concealedMelds) {
      if (meld.length == 4) {
        if (meld.first.isFeng) {
          points += 2 + 1; // 风牌杠 + 暗杠
        } else if (meld.first.isJian) {
          points += 3 + 1; // 箭牌杠 + 暗杠
        } else {
          points += 1 + 1; // 其他牌杠 + 暗杠
        }
      }
    }
    
    return points;
  }
  
  /// 计算包牌倍数
  /// 根据吃/碰口数返回翻倍系数
  static int calculateBaoMultiplier(int chowCount, int pongCount) {
    final total = chowCount + pongCount;
    if (total >= 4) return 5; // 包四家
    if (total >= 3) return 3; // 包三家
    return 1;
  }
  
  /// 计算自摸结算
  /// 返回 Map<输家, 输赢点数>
  static Map<Player, int> calculateSelfDrawnSettlement({
    required Player winner,
    required List<Player> losers,
    required int basePoints,
    required int roundMultiplier,
    required int globalMultiplier,
    required int Function(Player, Player) getBaoMultiplier,
  }) {
    final payments = <Player, int>{};
    final totalPoints = basePoints * roundMultiplier * globalMultiplier;
    
    for (final loser in losers) {
      final baoMultiplier = getBaoMultiplier(winner, loser);
      if (baoMultiplier > 1) {
        // 有互包关系，应用包牌倍数
        payments[loser] = totalPoints * baoMultiplier;
      }
      // 无互包关系则不支付
    }
    
    return payments;
  }
  
  /// 计算放冲结算
  static Map<Player, int> calculateRonSettlement({
    required Player winner,
    required Player uploader,
    required List<Player> otherLosers,
    required int basePoints,
    required int roundMultiplier,
    required int globalMultiplier,
    required int Function(Player, Player) getBaoMultiplier,
  }) {
    final payments = <Player, int>{};
    final totalPoints = basePoints * roundMultiplier * globalMultiplier;
    
    // 放冲者赔付
    final uploaderBaoMultiplier = getBaoMultiplier(winner, uploader);
    if (uploaderBaoMultiplier > 1) {
      // 互包玩家互相放冲 → 2倍
      payments[uploader] = totalPoints * 2;
    } else {
      payments[uploader] = totalPoints;
    }
    
    // 其他有互包关系的输家
    for (final loser in otherLosers) {
      final baoMultiplier = getBaoMultiplier(winner, loser);
      if (baoMultiplier > 1) {
        payments[loser] = payments[uploader]!; // 和放冲者输掉的一样
      }
    }
    
    return payments;
  }
  
  /// 检查是否满足无花自摸条件
  static bool checkNoFlowerSelfDraw({
    required HuType huType,
    required bool isSelfDrawn,
    required bool hasNoFlowerInExposed,
    required bool hasNoFengInHand,
  }) {
    if (!isSelfDrawn) return false;
    if (huType != HuType.pongPongHu && huType != HuType.hunYiSe) return false;
    if (!hasNoFlowerInExposed) return false;
    if (!hasNoFengInHand) return false;
    return true;
  }
}
