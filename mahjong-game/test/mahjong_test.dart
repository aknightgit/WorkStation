import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong_game/models/tile_model.dart';
import 'package:mahjong_game/models/player_model.dart';
import 'package:mahjong_game/logic/tile_type_detector.dart';
import 'package:mahjong_game/logic/hu_judge.dart';

void main() {
  group('胡牌判定测试', () {
    test('基本胡牌 - 333 444 555 66 77', () {
      // 构造简单胡牌牌型
      final tiles = [
        Tile(type: TileType.wan3, id: 1),
        Tile(type: TileType.wan3, id: 2),
        Tile(type: TileType.wan3, id: 3),
        Tile(type: TileType.wan4, id: 4),
        Tile(type: TileType.wan4, id: 5),
        Tile(type: TileType.wan4, id: 6),
        Tile(type: TileType.wan5, id: 7),
        Tile(type: TileType.wan5, id: 8),
        Tile(type: TileType.wan5, id: 9),
        Tile(type: TileType.wan6, id: 10),
        Tile(type: TileType.wan6, id: 11),
        Tile(type: TileType.wan6, id: 12),
        Tile(type: TileType.wan7, id: 13),
        Tile(type: TileType.wan7, id: 14),
      ];
      
      final result = HuJudge.canHu(tiles);
      expect(result, true, reason: '应能胡牌');
    });
    
    test('七对胡牌', () {
      final tiles = [
        Tile(type: TileType.wan1, id: 1),
        Tile(type: TileType.wan1, id: 2),
        Tile(type: TileType.wan2, id: 3),
        Tile(type: TileType.wan2, id: 4),
        Tile(type: TileType.wan3, id: 5),
        Tile(type: TileType.wan3, id: 6),
        Tile(type: TileType.wan4, id: 7),
        Tile(type: TileType.wan4, id: 8),
        Tile(type: TileType.wan5, id: 9),
        Tile(type: TileType.wan5, id: 10),
        Tile(type: TileType.wan6, id: 11),
        Tile(type: TileType.wan6, id: 12),
        Tile(type: TileType.wan7, id: 13),
        Tile(type: TileType.wan7, id: 14),
      ];
      
      final result = HuJudge.canHu(tiles);
      expect(result, true, reason: '七对应能胡牌');
    });
    
    test('不满足胡牌条件', () {
      final tiles = [
        Tile(type: TileType.wan1, id: 1),
        Tile(type: TileType.wan1, id: 2),
        Tile(type: TileType.wan2, id: 3),
        Tile(type: TileType.wan3, id: 4),
        Tile(type: TileType.wan4, id: 5),
        Tile(type: TileType.wan5, id: 6),
        Tile(type: TileType.wan6, id: 7),
      ];
      
      final result = HuJudge.canHu(tiles);
      expect(result, false, reason: '不应胡牌');
    });
  });
  
  group('牌型检测测试', () {
    test('清一色检测 - 全万子', () {
      final hand = [
        Tile(type: TileType.wan1, id: 1),
        Tile(type: TileType.wan1, id: 2),
        Tile(type: TileType.wan2, id: 3),
        Tile(type: TileType.wan3, id: 4),
        Tile(type: TileType.wan4, id: 5),
        Tile(type: TileType.wan5, id: 6),
        Tile(type: TileType.wan6, id: 7),
        Tile(type: TileType.wan7, id: 8),
        Tile(type: TileType.wan8, id: 9),
        Tile(type: TileType.wan9, id: 10),
        Tile(type: TileType.wan9, id: 11),
        Tile(type: TileType.wan9, id: 12),
      ];
      
      final result = TileTypeDetector.isQingYiSe(hand, []);
      expect(result, true, reason: '全万子应是清一色');
    });
    
    test('清一色检测 - 混搭不应成立', () {
      final hand = [
        Tile(type: TileType.wan1, id: 1),
        Tile(type: TileType.wan1, id: 2),
        Tile(type: TileType.wan2, id: 3),
        Tile(type: TileType.wan3, id: 4),
        Tile(type: TileType.tong1, id: 5),
        Tile(type: TileType.tong1, id: 6),
      ];
      
      final result = TileTypeDetector.isQingYiSe(hand, []);
      expect(result, false, reason: '万子和筒子混搭不是清一色');
    });
    
    test('风一色检测', () {
      final hand = [
        Tile(type: TileType.dong, id: 1),
        Tile(type: TileType.dong, id: 2),
        Tile(type: TileType.nan, id: 3),
        Tile(type: TileType.nan, id: 4),
        Tile(type: TileType.xi, id: 5),
        Tile(type: TileType.xi, id: 6),
        Tile(type: TileType.bei, id: 7),
        Tile(type: TileType.bei, id: 8),
        Tile(type: TileType.dong, id: 9),
        Tile(type: TileType.nan, id: 10),
        Tile(type: TileType.xi, id: 11),
        Tile(type: TileType.bei, id: 12),
      ];
      
      final result = TileTypeDetector.isFengYiSe(hand, []);
      expect(result, true, reason: '全风牌应是风一色');
    });
    
    test('五毒散检测', () {
      final hand = [
        Tile(type: TileType.wan1, id: 1),
        Tile(type: TileType.tong1, id: 2),
        Tile(type: TileType.tiao1, id: 3),
        Tile(type: TileType.dong, id: 4),
        Tile(type: TileType.zhong, id: 5),
      ];
      
      final result = TileTypeDetector.isWuDuSan(hand);
      expect(result, true, reason: '五门都有且无对子应是五毒散');
    });
    
    test('五毒散检测 - 有对子不应成立', () {
      final hand = [
        Tile(type: TileType.wan1, id: 1),
        Tile(type: TileType.wan1, id: 2),
        Tile(type: TileType.tong1, id: 3),
        Tile(type: TileType.tiao1, id: 4),
        Tile(type: TileType.dong, id: 5),
      ];
      
      final result = TileTypeDetector.isWuDuSan(hand);
      expect(result, false, reason: '有对子不是五毒散');
    });
  });
  
  group('十三幺检测', () {
    test('十三幺正确牌型', () {
      final tiles = [
        Tile(type: TileType.wan1, id: 1),
        Tile(type: TileType.wan9, id: 2),
        Tile(type: TileType.tong1, id: 3),
        Tile(type: TileType.tong9, id: 4),
        Tile(type: TileType.tiao1, id: 5),
        Tile(type: TileType.tiao9, id: 6),
        Tile(type: TileType.dong, id: 7),
        Tile(type: TileType.nan, id: 8),
        Tile(type: TileType.xi, id: 9),
        Tile(type: TileType.bei, id: 10),
        Tile(type: TileType.zhong, id: 11),
        Tile(type: TileType.fa, id: 12),
        Tile(type: TileType.bai, id: 13),
        Tile(type: TileType.wan1, id: 14), // 一对
      ];
      
      final result = TileTypeDetector.isShiSanYao(tiles);
      expect(result, true, reason: '应检测为十三幺');
    });
  });
}
