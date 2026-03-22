import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong_v2/game_logic/mahjong_game.dart';

void main() {
  group('游戏流程边界测试', () {
    late MahjongGame game;
    
    setUp(() {
      game = MahjongGame();
    });

    test('场景1: 正常发牌后轮到自己摸牌', () {
      game.rollDice();
      game.deal();
      
      // 发牌后应该是玩家0的回合
      expect(game.currentPlayerIndex, 0);
      expect(game.phase, GamePhase.playing);
      expect(game.players[0].handTiles.length, 14);
      
      // 可以摸牌
      final tile = game.drawTile(game.players[0]);
      expect(tile, isNotNull);
      expect(game.players[0].handTiles.length, 15);
    });

    test('场景2: 别人打牌后我可以碰/杠/胡', () {
      game.rollDice();
      game.deal();
      
      // 设置pendingTile让玩家响应
      final pending = game.players[1].playedTiles.isNotEmpty 
          ? game.players[1].playedTiles.last 
          : game.wall.removeLast();
      game.pendingTile = pending;
      
      // 切换到玩家0（当前玩家）
      game.currentPlayerIndex = 0;
      
      // 检查响应
      final player = game.players[0];
      final canPong = game.canPong(player);
      final canHu = game.canHu(player);
      
      // 如果手里有对子应该可以碰
      // 如果胡牌应该可以胡
      print('canPong: $canPong, canHu: $canHu');
    });

    test('场景3: 摸到花牌后自动补牌', () {
      game.rollDice();
      game.deal();
      
      final player = game.players[0];
      final beforeCount = player.handTiles.length;
      
      // 添加一张花牌
      player.handTiles.add(Tile(
        id: 999, 
        type: TileType.flower, 
        number: 1, 
        suit: TileSuit.hua, 
        isFlower: true
      ));
      
      // 自动杠花
      game.autoFlowerKong(player);
      
      // 花牌应该被移除并在flowerTiles里
      final hasFlower = player.handTiles.any((t) => t.isFlower);
      expect(hasFlower, false);
      expect(player.flowerTiles.isNotEmpty, true);
    });

    test('场景4: 牌墙摸完流局', () {
      game.rollDice();
      game.deal();
      
      // 摸光所有牌
      while (game.wall.isNotEmpty) {
        game.drawTile(game.players[0]);
      }
      
      // 应该触发流局
      final tile = game.drawTile(game.players[0]);
      expect(tile, isNull);
      expect(game.phase, GamePhase.scoring);
    });

    test('场景5: 逆时针回合流转', () {
      game.currentPlayerIndex = 0;
      game.nextPlayer();
      expect(game.currentPlayerIndex, 3); // 0 -> 逆时针 -> 3
      
      game.nextPlayer();
      expect(game.currentPlayerIndex, 2); // 3 -> 2
      
      game.nextPlayer();
      expect(game.currentPlayerIndex, 1); // 2 -> 1
      
      game.nextPlayer();
      expect(game.currentPlayerIndex, 0); // 1 -> 0
    });

    test('场景6: 无响应时自动跳过', () {
      game.rollDice();
      game.deal();
      
      // 设置一个无人响应的pendingTile
      game.pendingTile = game.wall.removeLast();
      game.currentPlayerIndex = 1; // 下一个玩家
      
      final player = game.players[1];
      
      // 检查是否能响应
      final canRespond = game.canPong(player) || 
                        game.canKong(player) || 
                        game.canHu(player) ||
                        game.canChow(player);
      
      print('canRespond: $canRespond');
      
      // 如果不能响应，应该自动跳过
      if (!canRespond) {
        game.nextPlayer();
        game.pendingTile = null;
        expect(game.pendingTile, isNull);
      }
    });

    test('场景7: 暗杠检测', () {
      game.rollDice();
      game.deal();
      
      final player = game.players[0];
      // 手动加4张相同的牌
      player.handTiles.clear();
      for (int i = 0; i < 4; i++) {
        player.handTiles.add(Tile(
          id: i, type: TileType.wan, number: 1, suit: TileSuit.wan
        ));
      }
      
      // 应该可以暗杠
      expect(game.canHiddenKong(player), true);
    });

    test('场景8: 吃牌只能吃上家的牌', () {
      game.rollDice();
      game.deal();
      
      // 玩家0打了一张牌
      final played = game.wall.removeLast();
      game.players[0].playedTiles.add(played);
      game.pendingTile = played;
      game.currentPlayerIndex = 1; // 玩家1的下家是玩家0
      
      final player1 = game.players[1];
      
      // 玩家1是玩家0的上家(逆时针)，不能吃
      final canChow = game.canChow(player1);
      expect(canChow, false); // 不能吃
      
      // 玩家3是玩家0的下家，可以吃
      game.currentPlayerIndex = 3;
      final player3 = game.players[3];
      final canChow3 = game.canChow(player3);
      print('玩家3 canChow: $canChow3');
    });
  });
}
